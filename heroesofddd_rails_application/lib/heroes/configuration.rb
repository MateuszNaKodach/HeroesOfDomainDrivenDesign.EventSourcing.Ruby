module Heroes
  class Configuration
    def call(event_store, command_bus)
      configure_modules(event_store, command_bus)
    end

    def configure_modules(event_store, command_bus)
      [
        Heroes::CreatureRecruitment::Configuration.new
      ].each { |c| c.call(event_store, command_bus) }
    end
  end
end
