module Heroes
  class CurrentDateController < ApplicationController
    def next_day
      game_id = params[:game_id]
      current_date = Heroes::Calendar::CurrentDateReadModel::State.find_by(game_id: game_id)

      if current_date
        finish_day = Heroes::Calendar::FinishDay.new(
          month: current_date.month,
          week: current_date.week,
          day: current_date.day
        )
        execute_command(finish_day)

        next_date = calculate_next_date(current_date)
        start_day = Heroes::Calendar::StartDay.new(
          month: next_date[:month],
          week: next_date[:week],
          day: next_date[:day]
        )
        execute_command(start_day)

        flash[:notice] = "Advanced to the next day"
      else
        flash[:alert] = "Current date not found"
      end

      redirect_back(fallback_location: root_path)
    end

    private

    def execute_command(command)
      command_bus.call(command, BuildingBlocks::Application::AppContext.for_game(params[:game_id]))
    end

    def calculate_next_date(current_date)
      day = current_date.day + 1
      week = current_date.week
      month = current_date.month

      if day > 7
        day = 1
        week += 1
      end

      if week > 4
        week = 1
        month += 1
      end

      { month: month, week: week, day: day }
    end
  end
end