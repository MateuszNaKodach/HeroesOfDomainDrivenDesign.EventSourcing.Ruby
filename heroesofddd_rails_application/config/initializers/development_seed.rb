# This file contains code that will run only in the development environment
# It seeds the database with initial data for testing and development purposes
require "building_blocks/application/app_context"

if Rails.env.development?
  Rails.application.config.after_initialize do
    game_id = SecureRandom.uuid
    puts "🎮 Loading initial data for game #{game_id}"
    metadata = ::BuildingBlocks::Application::AppContext.for_game(game_id)

    # Start day 1
    start_day_command = Heroes::Calendar::StartDay.new(
      1,
      1,
      1
    )
    Rails.configuration.command_bus.call(start_day_command, metadata)
    puts "📅 1 Day started"

    # Build Dwelling
    dwelling_id = SecureRandom.uuid
    creature_id = "angel"
    cost_per_troop = Heroes::SharedKernel::Resources::Cost.resources([ :GOLD, 3000 ], [ :GEM, 1 ])
    build_dwelling_command = Heroes::CreatureRecruitment::BuildDwelling.new(
      dwelling_id,
      creature_id,
      cost_per_troop
    )
    Rails.configuration.command_bus.call(build_dwelling_command, metadata)
    puts "🏠 Dwelling built with ID: #{dwelling_id}"

    # Increase Available Creatures
    increase_creatures_command = Heroes::CreatureRecruitment::IncreaseAvailableCreatures.new(
      dwelling_id,
      creature_id,
      10
    )
    Rails.configuration.command_bus.call(increase_creatures_command, metadata)
    puts "👼 Increased available creatures by 10"

    puts "✅ Development seed completed successfully!"
  end
end
