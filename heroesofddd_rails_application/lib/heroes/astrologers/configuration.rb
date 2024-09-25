module Heroes
  module Astrologers
    class Configuration
      def call(event_store, command_bus, event_registry)
        application_service = ::BuildingBlocks::Infrastructure::EventSourcingApplicationService.new(
          Dwelling,
          event_store,
          event_registry
        ) { |command| "CreatureRecruitment::Dwelling$#{command.dwelling_id}" }

        command_bus.register(
          BuildDwelling,
          BuildDwellingCommandHandler.new(application_service, event_registry)
        )
        command_bus.register(
          IncreaseAvailableCreatures,
          IncreaseAvailableCreaturesCommandHandler.new(application_service, event_registry)
        )
        command_bus.register(
          RecruitCreature,
          RecruitCreatureCommandHandler.new(application_service, event_registry)
        )

        Heroes::CreatureRecruitment::DwellingReadModel::Projection.new.call(event_store)
      end
    end
  end
end
