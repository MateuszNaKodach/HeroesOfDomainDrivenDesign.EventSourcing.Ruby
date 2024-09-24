module Heroes
  module CreatureRecruitment
    class DwellingsController < ApplicationController
      def index
      end

      def show
        dwelling_id = params[:id]
        @dwelling = DwellingReadModel::State.find_by(id: dwelling_id)
        if @dwelling
          render template: "heroes/creature_recruitment/dwellings/index"
        else
          render json: { error: "Dwelling not found" }, status: :not_found
        end
      end

      def recruit
        dwelling_id = params[:id]
        recruit_count = params[:recruit_count].to_i
        dwelling = DwellingReadModel::State.find_by(id: dwelling_id)

        if dwelling
          command = RecruitCreature.new(dwelling.id, dwelling.creature_id, recruit_count)

          begin
            command_bus.call(command)
            flash[:notice] = "Successfully recruited #{recruit_count} #{dwelling.creature_id.pluralize}"
          rescue StandardError => e
            flash[:alert] = "Failed to recruit creatures: #{e.message}"
          end
        else
          flash[:alert] = "Dwelling not found"
        end

        redirect_to heroes_creature_recruitment_dwelling_path(dwelling_id)
      end
    end
  end
end