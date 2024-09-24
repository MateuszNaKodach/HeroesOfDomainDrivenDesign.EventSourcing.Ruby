require "real_event_store_integration_test_case"
require "minitest/autorun"
require "minitest/spec"

module Heroes
  module CreatureRecruitment
    class DwellingReadModelApplicationTest < RealEventStoreIntegrationTestCase
      def setup
        super
        @dwelling_id = SecureRandom.uuid
        @creature_id = "black_dragon"
        @cost_per_troop = Heroes::SharedKernel::Resources::Cost.resources([:GOLD, 4000], [:SULFUR, 2])
        @stream_name = "CreatureRecruitment::Dwelling$#{@dwelling_id}"
      end

      def test_create_on_dwelling_built
        # given
        given_domain_event(@stream_name, DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))

        # when
        state = DwellingReadModel::State.find_by(id: @dwelling_id)

        # then
        expected_state = DwellingReadModel::State.new(id: @dwelling_id,
                                                      creature_id: @creature_id,
                                                      available_creatures: 0,
                                                      cost_per_troop: @cost_per_troop)
        assert_equal expected_state, state
      end

      def test_update_on_available_creatures_changed
        # given
        given_domain_event(@stream_name, DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))
        given_domain_event(@stream_name, AvailableCreaturesChanged.new(@dwelling_id, @creature_id, 99))

        # when
        state = DwellingReadModel::State.find_by(id: @dwelling_id)

        # then
        expected_state = DwellingReadModel::State.new(id: @dwelling_id,
                                                      creature_id: @creature_id,
                                                      available_creatures: 99,
                                                      cost_per_troop: @cost_per_troop)
        assert_equal expected_state, state
      end

    end
  end
end
