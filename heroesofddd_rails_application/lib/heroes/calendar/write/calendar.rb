module Heroes
  module Calendar
    module Calendar
      State = Data.define(:current_day, :current_week, :current_month)

      class << self
        def decide(command, state)
          case command
          when StartDay
            handle_start_day(command, state)
          when FinishDay
            handle_finish_day(command, state)
          else
            raise "Unknown command"
          end
        end

        def evolve(state, event)
          case event
          when DayStarted
            State.new(
              current_day: event.day,
              current_week: event.week,
              current_month: event.month
            )
          when DayFinished
            state
          else
            raise "Unknown event"
          end
        end

        def initial_state
          State.new(current_day: 0, current_week: 0, current_month: 0)
        end

        private

        def handle_start_day(command, state)
          validate_start_day(command, state)
          [ DayStarted.new(month: command.month, week: command.week, day: command.day) ]
        end

        def handle_finish_day(command, state)
          validate_finish_day(command, state)
          [ DayFinished.new(month: command.month, week: command.week, day: command.day) ]
        end

        def validate_start_day(command, state)
          raise CannotSkipDays unless next_day?(command, state)
        end

        def validate_finish_day(command, state)
          raise CanOnlyFinishCurrentDay unless current_day?(command, state)
        end

        def next_day?(command, state)
          return true if state.current_day == 0  # First day

          next_day = state.current_day + 1
          next_week = state.current_week
          next_month = state.current_month

          if next_day > 7
            next_day = 1
            next_week += 1
          end

          if next_week > 4
            next_week = 1
            next_month += 1
          end

          command.day == next_day && command.week == next_week && command.month == next_month
        end

        def current_day?(command, state)
          command.day == state.current_day &&
            command.week == state.current_week &&
            command.month == state.current_month
        end
      end
    end
  end
end
