require "test_helper"
require "building_blocks/application/app_context"

class DwellingsIntegrationTest < ActionDispatch::IntegrationTest
  include EventStoreTest

  def setup
    super
    @dwelling_id = SecureRandom.uuid
    @creature_id = "angel"
    @cost_per_troop = Heroes::SharedKernel::Resources::Cost.resources([:GOLD, 3000], [:GEM, 1])
    @game_id = SecureRandom.uuid
    @app_context = ::BuildingBlocks::Application::AppContext.for_game(@game_id)
    @stream_name = "Game::$#{@game_id}::CreatureRecruitment::Dwelling$#{@dwelling_id}"
  end

  test "viewing the recruitment page" do
    # Given
    given_domain_event(@stream_name, Heroes::CreatureRecruitment::DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))
    given_domain_event(@stream_name, Heroes::CreatureRecruitment::AvailableCreaturesChanged.new(@dwelling_id, @creature_id, 10))

    # When
    get heroes_game_creature_recruitment_dwelling_path(@game_id, @dwelling_id)

    # Then
    assert_response :success
    assert_select "#dwelling-#{@dwelling_id}" do
      assert_select ".recruitment__title", "Recruit Angels"
      assert_select ".recruitment__count-value", "10"
      assert_select ".recruitment__slider-input[max='10']"
    end
  end

  test "recruiting creatures successfully" do
    # Given
    given_domain_event(@stream_name, Heroes::CreatureRecruitment::DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))
    given_domain_event(@stream_name, Heroes::CreatureRecruitment::AvailableCreaturesChanged.new(@dwelling_id, @creature_id, 10))

    # When
    post recruit_heroes_game_creature_recruitment_dwelling_path(@game_id, @dwelling_id),
         params: { recruit_count: 5 },
         as: :turbo_stream

    # Then
    assert_response :success
    assert_turbo_stream action: :replace, target: "dwelling-#{@dwelling_id}"
    assert_select "#dwelling-#{@dwelling_id}" do
      assert_select ".recruitment__count-value", "5"
    end
  end

  test "viewing a non-existent dwelling" do
    # Given
    non_existent_id = SecureRandom.uuid

    # When
    get heroes_game_creature_recruitment_dwelling_path(@game_id, non_existent_id)

    # Then
    assert_response :not_found
  end

  test "recruiting zero creatures" do
    # Given
    given_domain_event(@stream_name, Heroes::CreatureRecruitment::DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))
    given_domain_event(@stream_name, Heroes::CreatureRecruitment::AvailableCreaturesChanged.new(@dwelling_id, @creature_id, 10))

    # When
    post recruit_heroes_game_creature_recruitment_dwelling_path(@game_id, @dwelling_id),
         params: { recruit_count: 0 },
         as: :turbo_stream

    # Then
    assert_response :success
    assert_turbo_stream action: :replace, target: "dwelling-#{@dwelling_id}"
    assert_select "#dwelling-#{@dwelling_id}" do
      assert_select ".recruitment__count-value", "10"
    end
  end

  def default_app_context
    @app_context
  end
end