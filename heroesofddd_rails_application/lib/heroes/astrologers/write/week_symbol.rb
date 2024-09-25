require "heroes/astrologers/write/proclaim_week_symbol/command_proclaim_week_symbol"
require "heroes/astrologers/write/proclaim_week_symbol/rule_one_symbol_per_week"
require "heroes/astrologers/write/proclaim_week_symbol/event_week_symbol_proclaimed"

module Heroes
  module Astrologers
    module WeekSymbol
      Current = Data.define(:month, :week, :week_of, :growth)

      class << self
        def decide(command, state)
          case command
          when ProclaimWeekSymbol
            proclaim(command, state)
          else
            raise "Unknown command"
          end
        end

        def evolve(state, event)
          case event
          when WeekSymbolProclaimed
            Current.new(month: event.month,
                        week: event.week,
                        week_of: event.week_of,
                        growth: event.growth)
          else
            raise "Unknown event"
          end
        end

        def initial_state
          Current.new(0, 0, nil, nil)
        end

        def proclaim(command, state)
          current_week_no = week_no state.month, state.week
          command_week_no = week_no command.month, command.week
          raise ::Heroes::Astrologers::OnlyOneSymbolPerWeek if current_week_no >= command_week_no
            [
              WeekSymbolProclaimed.new(month: command.month,
                                       week: command.week,
                                       week_of: command.week_of,
                                       growth: command.growth)
            ]
        end

        private

        def week_no(month, week)
          ((month - 1) * 4) + week
        end
      end
    end
  end
end
