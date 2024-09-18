require "in_memory_event_store_test_case"

module Heroes
  module CreatureRecruitment
    class CreatureRecruitmentModuleTest < InMemoryEventStoreTestCase
      @dwelling_id = "portal_of_glory"
      @creature_id = "angel"
      @cost_per_troop = Heroes::SharedKernel::Resources::Cost.resources([ :GOLD, 3000 ], [ :CRYSTAL, 1 ])

      def test_given_nothing_when_build_dwelling_then_success()
        # when
        build_dwelling = BuildDwelling.new(@dwelling_id, @creature_id, @cost_per_troop)
        action = -> { execute_command(build_dwelling) }

        # then
        assert_nothing_raised(&action)
      end

    end
  end
end