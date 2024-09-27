module Heroes
  module CreatureRecruitment
    module DwellingsHelper
      def render_dwelling(dwelling, form)
        render partial: 'heroes/creature_recruitment/dwellings/dwelling', locals: {
          dwelling: dwelling,
          form: form
        }
      end
    end
  end
end