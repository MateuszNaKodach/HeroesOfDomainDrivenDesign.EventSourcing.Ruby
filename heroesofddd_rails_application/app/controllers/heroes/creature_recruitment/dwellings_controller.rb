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
        @dwelling = DwellingReadModel::State.find_by(game_id: game_id, id: dwelling_id)

        if @dwelling
          if recruit_count > 0
            command = RecruitCreature.new(@dwelling.id, @dwelling.creature_id, recruit_count)
            begin
              command_bus.call(command, BuildingBlocks::Application::AppContext.for_game(game_id))
              flash.now[:notice] = "Successfully recruited #{recruit_count} #{@dwelling.creature_id.pluralize.capitalize}"
              @dwelling.reload  # Reload the dwelling to get updated data
            rescue StandardError => e
              flash.now[:alert] = "Failed to recruit creatures: #{e.message}"
            end
          else
            flash.now[:alert] = "Please select at least one creature to recruit."
          end

          respond_to do |format|
            format.html { redirect_to heroes_game_creature_recruitment_dwelling_path(game_id, dwelling_id) }
            format.turbo_stream do
              render turbo_stream: [
                turbo_stream.replace(dom_id_for(@dwelling), partial: 'heroes/creature_recruitment/dwellings/dwelling', locals: { dwelling: @dwelling }),
                turbo_stream.replace('flash', partial: 'layouts/flash')
              ]
            end
          end
        else
          flash[:alert] = "Dwelling not found"
          redirect_to heroes_game_creature_recruitment_dwelling_path(game_id, dwelling_id)
        end
      end

      private

      def dom_id_for(dwelling)
        "dwelling_#{dwelling.id}"
      end
    end
  end
end