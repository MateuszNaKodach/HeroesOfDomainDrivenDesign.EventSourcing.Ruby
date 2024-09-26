module Heroes
  module CreatureRecruitment
    class DwellingsController < ApplicationController
      def show
        game_id = params[:game_id]
        dwelling_id = params[:id]
        @dwelling = DwellingReadModel::State.find_by(game_id: game_id, id: dwelling_id)
        if @dwelling
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
              command_bus.call(command, BuildingBlocks::Application::Metadata.for_game(game_id))
              flash[:notice] = "Successfully recruited #{recruit_count} #{dwelling.creature_id.pluralize.capitalize}"
            rescue StandardError => e
              flash[:alert] = "Failed to recruit creatures: #{e.message}"
            end
          else
            flash[:alert] = "Please select at least one creature to recruit."
          end
        else
          flash[:alert] = "Dwelling not found"
        end

        redirect_to heroes_game_creature_recruitment_dwelling_path(game_id, dwelling_id)
      end
    end
  end
end