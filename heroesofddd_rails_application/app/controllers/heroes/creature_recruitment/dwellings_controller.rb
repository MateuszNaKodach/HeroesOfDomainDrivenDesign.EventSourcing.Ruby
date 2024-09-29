require "heroes/creature_recruitment/read/dwelling_read_model"
require "heroes/calendar/read/current_date_read_model"
require "heroes/creature_recruitment/write/recruit_creature/command_recruit_creature"
require "building_blocks/application/app_context"

module Heroes
  module CreatureRecruitment
    class DwellingsController < ApplicationController
      def show
        game_id = params[:game_id]
        dwelling_id = params[:id]
        @dwelling = DwellingReadModel::State.find_by(game_id: game_id, id: dwelling_id)
        if @dwelling
          @current_date = Heroes::Calendar::CurrentDateReadModel::State.find_by(game_id: game_id)
          render template: "heroes/creature_recruitment/dwellings/index"
        else
          render json: { error: "Dwelling not found" }, status: :not_found
        end
      end

      def recruit
        game_id = params[:game_id]
        dwelling_id = params[:id]
        recruit_count = params[:recruit_count].to_i
        dwelling = DwellingReadModel::State.find_by(game_id: game_id, id: dwelling_id)

        if dwelling
          if recruit_count > 0
            command = RecruitCreature.new(dwelling.id, dwelling.creature_id, recruit_count)
            begin
              command_bus.call(command, BuildingBlocks::Application::AppContext.for_game(game_id))
              @message = { type: :notice, text: "Successfully recruited #{recruit_count} #{dwelling.creature_id.pluralize.capitalize}" }
              dwelling.reload
            rescue StandardError => e
              @message = { type: :alert, text: "Failed to recruit creatures: #{e.message}" }
            end
          else
            @message = { type: :alert, text: "Please select at least one creature to recruit." }
          end
        else
          @message = { type: :alert, text: "Dwelling not found" }
        end
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "dwelling-#{dwelling_id}",
              partial: 'heroes/creature_recruitment/dwellings/dwelling',
              locals: { dwelling: dwelling, message: @message }
            )
          end
          format.html { redirect_to heroes_game_creature_recruitment_dwelling_path(game_id, dwelling_id) }
        end
      end
    end
  end
end
