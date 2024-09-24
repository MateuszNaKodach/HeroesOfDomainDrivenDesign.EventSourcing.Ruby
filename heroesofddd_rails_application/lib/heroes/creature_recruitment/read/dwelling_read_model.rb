module Heroes
  module CreatureRecruitment
    module DwellingReadModel
      class State < ApplicationRecord
        self.table_name = "dwelling_read_models"

        validates :id, presence: true, uniqueness: true
        validates :creature_id, presence: true
        validates :available_creatures, presence: true, numericality: { greater_than_or_equal_to: 0 }
        validates :cost_per_troop, presence: true
      end

      class Projection
        def call(event_store)
          event_store.subscribe(
            ->(event) { DwellingReadModel::State.create(id: event.data[:dwelling_id],
                                                        creature_id: event.data[:creature_id],
                                                        available_creatures: event.data[:available_creatures],
                                                        cost_per_troop: event.data[:cost_per_troop]) },
            to: [ ::EventStore::Heroes::CreatureRecruitment::DwellingBuilt ])
          # event_store.subscribe(
          #   ->(event) { DwellingReadModel::State.find_by(id: event.data[:dwelling_id]).update(available_creatures: event.data[:changed_to]) },
          #   to: [ ::EventStore::Heroes::CreatureRecruitment::AvailableCreaturesChanged ])
        end
      end
    end
  end
end
