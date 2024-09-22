module Heroes
  module CreatureRecruitment
    class Configuration
      def call(event_store, command_bus, event_registry)
        event_registry.map_event_type(
          ::Heroes::CreatureRecruitment::DwellingBuilt,
          ::EventStore::Heroes::CreatureRecruitment::DwellingBuilt,
          ->(domain_event) {
            ::EventStore::Heroes::CreatureRecruitment::DwellingBuilt.from_domain(domain_event)
          },
          ->(store_event) {
            ::EventStore::Heroes::CreatureRecruitment::DwellingBuilt.to_domain(store_event)
          }
        )
        application_service = ::BuildingBlocks::Infrastructure::EventSourcingApplicationService.new(
          Dwelling,
          event_store,
          event_registry
        ) { |command| "CreatureRecruitment::Dwelling$#{command.dwelling_id}" }
        command_bus.register(
          BuildDwelling,
          BuildDwellingCommandHandler.new(application_service)
        )
      end
    end
  end
end
