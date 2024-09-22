module Heroes
  class Configuration
    def call(event_store, command_bus, query_bus, event_mapper)
      configure_modules(event_store, command_bus, event_mapper)

      Heroes::CreatureRecruitment::DwellingProjection.new.call(event_store)
    end

    def configure_modules(event_store, command_bus, event_mapper)
      [
        Heroes::CreatureRecruitment::Configuration.new
      ].each { |c| c.call(event_store, command_bus, event_mapper) }
    end
  end
end
