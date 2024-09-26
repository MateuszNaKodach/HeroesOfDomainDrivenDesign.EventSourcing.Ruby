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
        @cost_per_troop = Heroes::SharedKernel::Resources::Cost.resources([ :GOLD, 4000 ], [ :SULFUR, 2 ])

        @game_id = SecureRandom.uuid
        @stream_name ="Game::$#{@game_id}::CreatureRecruitment::Dwelling$#{@dwelling_id}"
        @app_context = ::BuildingBlocks::Application::AppContext.for_game(@game_id)
      end

      def test_create_on_dwelling_built
        # given
        given_domain_event(@stream_name, DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))

        # when
        state = DwellingReadModel::State.find_by(game_id: @game_id, id: @dwelling_id)

        # then
        expected_state = DwellingReadModel::State.new(id: @dwelling_id,
                                                      game_id: @game_id,
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
        state = DwellingReadModel::State.find_by(game_id: @game_id, id: @dwelling_id)

        # then
        expected_state = DwellingReadModel::State.new(id: @dwelling_id,
                                                      game_id: @game_id,
                                                      creature_id: @creature_id,
                                                      available_creatures: 99,
                                                      cost_per_troop: @cost_per_troop)
        assert_equal expected_state, state
      end

      def test_update_on_creature_recruited
        # given
        given_domain_event(@stream_name, DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))
        given_domain_event(@stream_name, AvailableCreaturesChanged.new(@dwelling_id, @creature_id, 99))
        given_domain_event(@stream_name, CreatureRecruited.new(@dwelling_id, @creature_id, 1, @cost_per_troop))

        # when
        state = DwellingReadModel::State.find_by(game_id: @game_id, id: @dwelling_id)

        # then
        expected_state = DwellingReadModel::State.new(id: @dwelling_id,
                                                      game_id: @game_id,
                                                      creature_id: @creature_id,
                                                      available_creatures: 98,
                                                      cost_per_troop: @cost_per_troop)
        assert_equal expected_state, state
      end

      def default_app_context
        @app_context
      end
    end
  end
end
