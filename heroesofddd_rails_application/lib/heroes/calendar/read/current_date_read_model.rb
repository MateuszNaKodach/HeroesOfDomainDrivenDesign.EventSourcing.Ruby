module Heroes
  module Calendar
    module CurrentDateReadModel
      class Migration
        def change
          ActiveRecord::Base.connection.create_table :current_date_read_models, id: false do |t|
            t.string :game_id, null: false, primary_key: true
            t.integer :year, null: false, default: 0
            t.integer :month, null: false, default: 0
            t.integer :day, null: false, default: 0

            t.timestamps
            t.integer :lock_version, null: false, default: 0
          end
        end
      end

      class State < ApplicationRecord
        self.table_name = "current_date_read_models"

        validates :game_id, presence: true, uniqueness: true
        validates :year, presence: true, numericality: { greater_than_or_equal_to: 1 }
        validates :month, presence: true, numericality: { greater_than_or_equal_to: 1 }
        validates :day, presence: true, numericality: { greater_than_or_equal_to: 1 }
      end

      class Projection
        def call(event_store)
          event_store.subscribe(
            ->(event) {
              CurrentDateReadModel::State
                .find_or_create_by!(game_id: event.metadata[:game_id])
                .update!(
                  year: event.year[:year],
                  month: event.year[:month],
                  day: event.year[:day],
                )
            },
            to: [ ::EventStore::Heroes::Calendar::DayStarted ])
        end
      end
    end
  end
end
