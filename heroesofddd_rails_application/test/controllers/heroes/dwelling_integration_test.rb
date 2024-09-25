require "test_helper"

class DwellingsIntegrationTest < ActionDispatch::IntegrationTest
  include EventStoreTest

  def setup
    @dwelling_id = SecureRandom.uuid
    @creature_id = "angel"
    @cost_per_troop = Heroes::SharedKernel::Resources::Cost.resources(
                                                                        [ :GOLD, 3000 ],
                                                                        [ :GEM, 1 ]
                                                                      )
    @stream_name = "CreatureRecruitment::Dwelling$#{@dwelling_id}"
  end

  test "viewing the recruitment page" do
    # Given
    given_domain_event(@stream_name, Heroes::CreatureRecruitment::DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))
    given_domain_event(@stream_name, Heroes::CreatureRecruitment::AvailableCreaturesChanged.new(@dwelling_id, @creature_id, 10))

    # When
    get heroes_creature_recruitment_dwelling_path(@dwelling_id)

    # Then
    assert_response :success
    assert_select ".recruitment__title", "Recruit Angels"
    assert_select ".recruitment__count-value", "10"
    assert_select "#recruit-count", "0"
    assert_select ".recruitment__slider-input[max='10']"
  end

  test "recruiting creatures successfully" do
    # Given
    given_domain_event(@stream_name, Heroes::CreatureRecruitment::DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))
    given_domain_event(@stream_name, Heroes::CreatureRecruitment::AvailableCreaturesChanged.new(@dwelling_id, @creature_id, 10))

    # When
    post recruit_heroes_creature_recruitment_dwelling_path(@dwelling_id), params: { recruit_count: 5 }

    # Then
    assert_redirected_to heroes_creature_recruitment_dwelling_path(@dwelling_id)
    follow_redirect!
    assert_select ".recruitment__count-value", "5"
  end

  test "viewing a non-existent dwelling" do
    # Given
    non_existent_id = SecureRandom.uuid

    # When
    get heroes_creature_recruitment_dwelling_path(non_existent_id)

    # Then
    assert_response :not_found
  end

  test "updating total cost when changing recruit count" do
    # Given
    given_domain_event(@stream_name, Heroes::CreatureRecruitment::DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))
    given_domain_event(@stream_name, Heroes::CreatureRecruitment::AvailableCreaturesChanged.new(@dwelling_id, @creature_id, 10))

    # When
    get heroes_creature_recruitment_dwelling_path(@dwelling_id)

    # Then
    assert_response :success
    assert_select "script", /document\.getElementById\('total-gold'\)\.textContent = count \* 3000/
    assert_select "script", /document\.getElementById\('total-gem'\)\.textContent = count \* 1/
  end

  test "recruiting zero creatures" do
    # Given
    given_domain_event(@stream_name, Heroes::CreatureRecruitment::DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))
    given_domain_event(@stream_name, Heroes::CreatureRecruitment::AvailableCreaturesChanged.new(@dwelling_id, @creature_id, 10))

    # When
    post recruit_heroes_creature_recruitment_dwelling_path(@dwelling_id), params: { recruit_count: 0 }

    # Then
    assert_redirected_to heroes_creature_recruitment_dwelling_path(@dwelling_id)
    follow_redirect!
    assert_select ".recruitment__count-value", "10"
    assert_select ".recruitment__message-box__text", "Please select at least one creature to recruit."
    assert_select ".recruitment__message-box__text--error"
  end
end
