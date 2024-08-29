require "minitest/autorun"
require_relative "../../../../../lib/heroes/modules/creature_recruitment/dwelling"
require_relative "../../../../../lib/heroes/modules/creature_recruitment/write_build_dwelling"
require_relative "../../../../../lib/heroes/modules/shared_kernel/resources"


module Heroes
  module CreatureRecruitment
    class BuildDwellingTest < Minitest::Test
      def test_given_not_built_dwelling_when_build_dwelling_then_dwelling_built
        # given
        state = Heroes::CreatureRecruitment::Dwelling::NotBuilt.new

        # when
        dwelling_id = "portal_of_glory"
        creature_id = "angel"
        cost_per_troop = Heroes::SharedKernel::Cost.resources([ :GOLD, 3000 ], [ :CRYSTAL, 1 ])
        command = Heroes::CreatureRecruitment::BuildDwelling.new(dwelling_id, creature_id, cost_per_troop)
        result = Heroes::CreatureRecruitment::Dwelling.decide(command, state)

        # then
        expected_events = [ Heroes::CreatureRecruitment::DwellingBuilt.new(dwelling_id, creature_id, cost_per_troop) ]
        assert_equal(expected_events, result)
      end
    end
  end
end
