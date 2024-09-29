require "heroes/creature_recruitment/read/dwelling_read_model"
require "heroes/calendar/read/current_date_read_model"
require "heroes/creature_recruitment/write/recruit_creature/command_recruit_creature"
require "building_blocks/application/app_context"

# todo: consider last response from here:
# https://claude.ai/chat/a081c14c-26e0-4f92-8371-4e13470cd8c9

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
        result = process_recruitment(dwelling, recruit_count, game_id)

        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "dwelling-#{dwelling_id}",
              partial: "heroes/creature_recruitment/dwellings/dwelling",
              locals: { dwelling: dwelling, message: result }
            )
          end
          format.html { redirect_to heroes_game_creature_recruitment_dwelling_path(game_id, dwelling_id) }
          format.json {
            case result
            in { type: :alert }
              render json: { error: result.text }, status: :bad_request
            else
              render json: { error: result.text }, status: :ok
            end
          }
        end
      end

      private

      def process_recruitment(game_id, dwelling, recruit_count)
        return { type: :alert, text: "Dwelling not found" } unless dwelling
        return { type: :alert, text: "Please select at least one creature to recruit." } unless recruit_count.positive?

        recruit_creatures(game_id, dwelling, recruit_count)
      end

      def recruit_creatures(game_id, dwelling, recruit_count)
        command = Heroes::CreatureRecruitment::RecruitCreature.new(dwelling.id, dwelling.creature_id, recruit_count)
        command_bus.call(command, BuildingBlocks::Application::AppContext.for_game(game_id))
        dwelling.reload
        { type: :notice, text: "Successfully recruited #{recruit_count} #{dwelling.creature_id.pluralize.capitalize}" }
      rescue StandardError => e
        { type: :alert, text: "Failed to recruit creatures: #{e.message}" }
      end
    end
  end
end
