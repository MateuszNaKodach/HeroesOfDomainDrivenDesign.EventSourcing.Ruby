require "building_blocks/infrastructure/event_sourcing_application_service"
require_relative "write/start_day/command_start_day"
require_relative "write/finish_day/command_finish_day"
require_relative "write/calendar"
require_relative "read/current_date_read_model"

module Heroes
  module Calendar
    class Configuration
      def call(event_store, command_bus, event_registry)
        application_service = ::BuildingBlocks::Infrastructure::EventSourcingApplicationService.new(
          Calendar,
          event_store,
          event_registry
        ) { |_, metadata| "Game::$#{metadata[:game_id]}::Calendar" }

        command_bus.register(
          StartDay,
          StartDayCommandHandler.new(application_service, event_registry)
        )

        command_bus.register(
          FinishDay,
          FinishDayCommandHandler.new(application_service, event_registry)
        )

        ::Heroes::Calendar::CurrentDateReadModel::Projection.new.call(event_store)
      end
    end
  end
end
