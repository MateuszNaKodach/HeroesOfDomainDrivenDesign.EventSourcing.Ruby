module Heroes
  module CreatureRecruitment
    class Configuration
      def call(event_store, command_bus, event_type_mapper)
        command_bus.register(
          BuildDwelling,
          BuildDwellingCommandHandler.new(event_store)
        )
      end
    end
  end
end
