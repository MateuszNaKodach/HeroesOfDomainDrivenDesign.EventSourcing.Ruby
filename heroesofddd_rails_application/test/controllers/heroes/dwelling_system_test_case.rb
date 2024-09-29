require "application_system_test_case"
require "heroes/creature_recruitment/write/build_dwelling/event_dwelling_built"
require "heroes/creature_recruitment/write/change_available_creatures/event_available_creatures_changed"
require "building_blocks/application/app_context"

class DwellingSystemTest < ApplicationSystemTestCase
  include EventStoreTest

  def setup
    super
    @dwelling_id = SecureRandom.uuid
    @creature_id = "angel"
    @cost_per_troop = Heroes::SharedKernel::Resources::Cost.resources([ :GOLD, 3000 ], [ :GEM, 1 ])
    @game_id = SecureRandom.uuid
    @app_context = ::BuildingBlocks::Application::AppContext.for_game(@game_id)
    @stream_name = "Game::$#{@game_id}::CreatureRecruitment::Dwelling$#{@dwelling_id}"
  end

  test "updates total cost when changing recruit count" do
    # given
    given_domain_event(@stream_name, Heroes::CreatureRecruitment::DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))
    given_domain_event(@stream_name, Heroes::CreatureRecruitment::AvailableCreaturesChanged.new(@dwelling_id, @creature_id, 10))

    # when
    visit heroes_game_creature_recruitment_dwelling_path(@game_id, @dwelling_id)

    # then
    assert_selector ".recruitment__title", text: "Recruit Angels"
    assert_selector ".recruitment__count-value", text: "10"

    # and: initially, the recruit count should be 0
    assert_selector "[data-dwelling-target='recruitCount']", text: "0"
    assert_selector "#total-gold", text: "0"
    assert_selector "#total-gem", text: "0"

    # when: change the recruit count to 5
    find(".recruitment__slider-input").set(5)

    # then: updated the totals
    assert_selector "[data-dwelling-target='recruitCount']", text: "5"
    assert_selector "#total-gold", text: "15000"
    assert_selector "#total-gem", text: "5"

    # whenL change the recruit count to the maximum (10)
    find(".recruitment__slider-input").set(10)

    # then: updated the totals
    assert_selector "[data-dwelling-target='recruitCount']", text: "10"
    assert_selector "#total-gold", text: "30000"
    assert_selector "#total-gem", text: "10"
  end

  private

  def default_app_context
    @app_context
  end
end
