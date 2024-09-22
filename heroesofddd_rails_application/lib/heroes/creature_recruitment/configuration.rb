require "building_blocks/infrastructure/event_sourcing_application_service"
require "heroes/creature_recruitment/write/build_dwelling/command_build_dwelling"
require "heroes/creature_recruitment/write/recruit_creature/command_recruit_creature"
require "heroes/creature_recruitment/write/change_available_creatures/command_increase_available_creatures"
require "heroes/creature_recruitment/write/dwelling"

module Heroes
  module CreatureRecruitment
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
      end
    end
  end
end
