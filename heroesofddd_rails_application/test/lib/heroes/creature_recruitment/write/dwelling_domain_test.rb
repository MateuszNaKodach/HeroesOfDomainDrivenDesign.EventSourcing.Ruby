require "minitest/autorun"
require "heroes/creature_recruitment/write/build_dwelling/command_build_dwelling"
require "heroes/creature_recruitment/write/dwelling"
require "heroes/shared_kernel/resources"


module Heroes
  module CreatureRecruitment
    DECIDER = Heroes::CreatureRecruitment::Dwelling
    class DwellingDomainTest < Minitest::Test
      def setup
        super
        @dwelling_id = "portal_of_glory"
        @creature_id = "angel"
        @cost_per_troop = Heroes::SharedKernel::Resources::Cost.resources([ :GOLD, 3000 ], [ :GEM, 1 ])
      end

      def test_given_not_built_dwelling_when_build_dwelling_then_dwelling_built
        # given
        given_events = []

        # when
        command = Heroes::CreatureRecruitment::BuildDwelling.new(@dwelling_id, @creature_id, @cost_per_troop)
        result = decide(given_events, command)

        # then
        expected_events = [ Heroes::CreatureRecruitment::DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop) ]
        assert_equal expected_events, result
      end

      def test_given_built_dwelling_when_build_dwelling_then_failed
        # given
        given_events = [
          Heroes::CreatureRecruitment::DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop)
        ]

        # when
        command = Heroes::CreatureRecruitment::BuildDwelling.new(@dwelling_id, @creature_id, @cost_per_troop)

        # then
        assert_raises(OnlyNotBuiltBuildingCanBeBuild) do
          decide(given_events, command)
        end
      end

      private

      def decide(given_events, command)
        DECIDER.decide(command, state_from(given_events))
      end

      def state_from(events)
        events.reduce(DECIDER.initial_state) { |state, event| DECIDER.evolve(state, event) }
      end
    end
  end
end
