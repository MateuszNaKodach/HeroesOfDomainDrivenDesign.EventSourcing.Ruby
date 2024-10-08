module Heroes
  module Calendar
    module CurrentDateReadModel
      class Migration
        def change
          ActiveRecord::Base.connection.create_table :current_date_read_models, id: false do |t|
            t.string :game_id, null: false, primary_key: true
            t.integer :month, null: false, default: 0
            t.integer :week, null: false, default: 0
            t.integer :day, null: false, default: 0

            t.timestamps
            t.integer :lock_version, null: false, default: 0
          end
        end
      end

      class State < ApplicationRecord
        self.table_name = "current_date_read_models"

        validates :game_id, presence: true, uniqueness: true
        validates :month, presence: true
        validates :week, presence: true
        validates :day, presence: true
      end

      class Projection
        def call(event_store)
          event_store.subscribe(
            ->(event) {
              CurrentDateReadModel::State
                .find_or_create_by!(game_id: event.metadata[:game_id])
                .update!(
                  month: event.data[:month],
                  week: event.data[:week],
                  day: event.data[:day],
                )
            },
            to: [ ::EventStore::Heroes::Calendar::DayStarted ])
        end
      end
    end
  end
end
