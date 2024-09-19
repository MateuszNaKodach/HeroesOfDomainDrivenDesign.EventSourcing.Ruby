module Heroes
  class Configuration
    def call(event_store, command_bus)
      event_type_mapper = EventTypeMapper.new
      configure_modules(event_store, command_bus, event_type_mapper)

      Heroes::CreatureRecruitment::DwellingProjection.new.call(event_store, event_type_mapper)
    end

    def configure_modules(event_store, command_bus, event_type_mapper)
      [
        Heroes::CreatureRecruitment::Configuration.new
      ].each { |c| c.call(event_store, command_bus, event_type_mapper) }
    end
  end
end
