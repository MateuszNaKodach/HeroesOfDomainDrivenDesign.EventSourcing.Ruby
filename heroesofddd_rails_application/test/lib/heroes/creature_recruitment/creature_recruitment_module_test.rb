require "in_memory_event_store_test_case"
require "real_event_store_integration_test_case"

module Heroes
  module CreatureRecruitment
    class CreatureRecruitmentModuleTest < RealEventStoreIntegrationTestCase
      def setup
        super
        @dwelling_id = SecureRandom.uuid
        @creature_id = "angel"
        @cost_per_troop = Heroes::SharedKernel::Resources::Cost.resources([ :GOLD, 3000 ], [ :CRYSTAL, 1 ])
      end

      def test_given_nothing_when_build_dwelling_then_success
        # given
        build_dwelling = BuildDwelling.new(@dwelling_id, @creature_id, @cost_per_troop)

        # when
        action = -> { execute_command(build_dwelling) }

        # then
        assert_nothing_raised(&action)
      end

      def test_given_dwelling_built_when_build_dwelling_then_success
        # given
        build_dwelling = BuildDwelling.new(@dwelling_id, @creature_id, @cost_per_troop)
        execute_command(build_dwelling)

        # when
        action = -> { execute_command(build_dwelling) }

        # then
        assert_nothing_raised(&action)
        read_model = DwellingReadModel.find_by(id: @dwelling_id)
        assert_not_nil(read_model)
      end
    end
  end
end
