require "test_helper"

class DwellingsIntegrationTest < ActionDispatch::IntegrationTest
  include EventStoreTest

  test "recruiting creatures" do
    # Given
    dwelling_id = SecureRandom.uuid
    creature_id = "angel"
    cost_per_troop = Heroes::SharedKernel::Resources::Cost.resources([ :GOLD, 3000 ], [ :GEM, 1 ])

    given_domain_event("CreatureRecruitment::Dwelling$#{dwelling_id}",
                       Heroes::CreatureRecruitment::DwellingBuilt.new(dwelling_id, creature_id, cost_per_troop))
    given_domain_event("CreatureRecruitment::Dwelling$#{dwelling_id}",
                       Heroes::CreatureRecruitment::AvailableCreaturesChanged.new(dwelling_id, creature_id, 10))

    # When
    post recruit_heroes_creature_recruitment_dwelling_path(dwelling_id), params: { recruit_count: 5 }

    # Then
    assert_redirected_to heroes_creature_recruitment_dwelling_path(dwelling_id)
    follow_redirect!
    assert_select ".creatures__count .count", "5" # Assuming the view shows the updated count
  end
end
