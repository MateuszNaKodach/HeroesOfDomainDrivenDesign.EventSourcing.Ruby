module Heroes
  class CalendarsController < ApplicationController
    def next_day
      game_id = params[:game_id]
      current_date = Heroes::Calendar::CurrentDateReadModel::State.find_by(game_id: game_id)

      finish_day = Heroes::Calendar::FinishDay.new(current_date.month, current_date.week, current_date.day)
      command_bus.call(finish_day, BuildingBlocks::Application::AppContext.for_game(game_id))

      next_day = calculate_next_day(current_date)
      start_day = Heroes::Calendar::StartDay.new(next_day[:month], next_day[:week], next_day[:day])
      command_bus.call(start_day, BuildingBlocks::Application::AppContext.for_game(game_id))

      @current_date = Heroes::Calendar::CurrentDateReadModel::State.find_by(game_id: game_id)

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("current-date", partial: "heroes/calendar/current_date") }
      end
    end

    private

    def calculate_next_day(current_date)
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