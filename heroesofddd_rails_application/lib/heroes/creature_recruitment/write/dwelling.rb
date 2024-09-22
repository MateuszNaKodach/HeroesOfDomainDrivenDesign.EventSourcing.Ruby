require_relative "./build_dwelling/rule_only_not_built"
require_relative "./build_dwelling/event_dwelling_built"
require_relative "./change_available_creatures/event_available_creatures_changed"
require_relative "./recruit_creature/event_creature_recruited"

module Heroes
  module CreatureRecruitment
    module Dwelling
      NotBuilt = Data.define
      Built = Data.define(:dwelling_id, :creature_id, :cost_per_troop, :available_creatures)

      class << self
        def decide(command, state)
          case command
          when BuildDwelling
            build(command, state)
          when IncreaseAvailableCreatures
            increase_available_creatures(command, state)
          when RecruitCreature
            recruit(command, state)
          else
            raise "Unknown command"
          end
        end

        def evolve(state, event)
          case event
          when DwellingBuilt
            Built.new(dwelling_id: event.dwelling_id,
                      creature_id: event.creature_id,
                      cost_per_troop: event.cost_per_troop,
                      available_creatures: 0)
          when AvailableCreaturesChanged
            state.with(available_creatures: event.changed_to)
          when CreatureRecruited
            state.with(available_creatures: state.available_creatures - command.recruit)
          else
            raise "Unknown event"
          end
        end

        def initial_state
          NotBuilt.new
        end

        private

        def build(command, state)
          raise ::Heroes::CreatureRecruitment::OnlyNotBuiltBuildingCanBeBuild unless state.is_a?(NotBuilt)

          [
            DwellingBuilt.new(dwelling_id: command.dwelling_id,
                              creature_id: command.creature_id,
                              cost_per_troop: command.cost_per_troop)
          ]
        end

        def increase_available_creatures(command, state)
          [
            AvailableCreaturesChanged.new(dwelling_id: command.dwelling_id,
                                          creature_id: command.creature_id,
                                          changed_to: state.available_creatures + command.increase_by)
          ]
        end

        def recruit(command, state)
          raise ::Heroes::CreatureRecruitment::RecruitCreaturesNotExceedAvailableCreatures if state.is_a?(NotBuilt) || (command.recruit > state.available_creatures)

          # todo: add total cost
          [
            CreatureRecruited.new(dwelling_id: command.dwelling_id,
                                  creature_id: command.creature_id,
                                  recruited: command.recruit)
          ]
        end
      end
    end
  end
end
