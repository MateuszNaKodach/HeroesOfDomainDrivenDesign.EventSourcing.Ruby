require "minitest/autorun"

module Heroes
  module CreatureRecruitment
    class BuildDwellingTest < Minitest::Test

      def test_given_not_built_dwelling_when_build_dwelling_then_dwelling_built
        # given
        state = Heroes::CreatureRecruitment::Dwelling::NotBuilt.new
        # when
        command = Heroes::CreatureRecruitment::BuildDwelling.new(dwelling_id: "1", creature_id: "1", cost_per_troop: 1)
        result = Heroes::CreatureRecruitment::Dwelling.decide(command, state)
        # then

        assert_equal([Heroes::CreatureRecruitment::DwellingBuilt.new(dwelling_id: "1", creature_id: "1", cost_per_troop: 1)], result)
      end

    end
  end
end