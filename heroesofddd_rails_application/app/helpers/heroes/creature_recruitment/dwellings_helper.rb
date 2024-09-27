module Heroes
  module CreatureRecruitment
    module DwellingsHelper
      def render_dwelling(dwelling)
        render partial: "heroes/creature_recruitment/dwellings/dwelling", locals: {
          dwelling: dwelling
        }
      end
    end
  end
end
