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
          else
            raise "Unknown command"
          end
        end

        def evolve(state, event)
          case event
          when DwellingBuilt
            Built.new(dwelling_id: event.dwelling_id, creature_id: event.creature_id, cost_per_troop: event.cost_per_troop, available_creatures: 0)
          else
            raise "Unknown event"
          end
        end

        def initial_state
          NotBuilt.new
        end

        private

        def build(command, state)
          if state.is_a?(Built)
            return []
          end
          [ DwellingBuilt.new(dwelling_id: command.dwelling_id, creature_id: command.creature_id, cost_per_troop: command.cost_per_troop) ]
        end
      end
    end
  end
end
