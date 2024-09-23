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
    end
  end
end
