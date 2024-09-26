module Heroes
  module CreatureRecruitment
    module DwellingReadModel
      class Migration
        def change
          ActiveRecord::Base.connection.create_table :dwelling_read_models, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
            t.string :game_id, null: false
            t.string :creature_id, null: false
            t.integer :available_creatures, null: false
            t.jsonb :cost_per_troop, null: false

            t.timestamps
            t.integer :lock_version, null: false, default: 0

            t.index [ :game_id, :id ], unique: true
          end
        end
      end

      class State < ApplicationRecord
        self.table_name = "dwelling_read_models"

        validates :id, presence: true
        validates :game_id, presence: true
        validates :creature_id, presence: true
        validates :available_creatures, presence: true, numericality: { greater_than_or_equal_to: 0 }
        validates :cost_per_troop, presence: true

        validates :id, uniqueness: { scope: :game_id }
      end

      class Projection
        def call(event_store)
          event_store.subscribe(
            ->(event) { DwellingReadModel::State.create(id: event.data[:dwelling_id],
                                                        game_id: event.metadata[:game_id],
                                                        creature_id: event.data[:creature_id],
                                                        available_creatures: 0,
                                                        cost_per_troop: event.data[:cost_per_troop]) },
            to: [ ::EventStore::Heroes::CreatureRecruitment::DwellingBuilt ])
          event_store.subscribe(
            ->(event) { DwellingReadModel::State.find_by(id: event.data[:dwelling_id], game_id: event.metadata[:game_id]).update(available_creatures: event.data[:changed_to]) },
            to: [ ::EventStore::Heroes::CreatureRecruitment::AvailableCreaturesChanged ])
          event_store.subscribe(
            ->(event) {
              state = DwellingReadModel::State.find_by(id: event.data[:dwelling_id], game_id: event.metadata[:game_id])
              recruited = event.data[:recruited]
              state.update!(available_creatures: state.available_creatures - recruited)
            },
            to: [ ::EventStore::Heroes::CreatureRecruitment::CreatureRecruited ])
        end
      end
    end
  end
end
