# This file contains code that will run only in the development environment
# It seeds the database with initial data for testing and development purposes

if Rails.env.development?
  Rails.application.config.after_initialize do
    dwelling_id = SecureRandom.uuid
    creature_id = "angel"
    cost_per_troop = Heroes::SharedKernel::Resources::Cost.resources([ [ :GOLD, 3000 ], [ :GEM, 1 ] ])

    # Build Dwelling
    build_dwelling_command = Heroes::CreatureRecruitment::BuildDwelling.new(
      dwelling_id,
      creature_id,
      cost_per_troop
    )
    Rails.configuration.command_bus.call(build_dwelling_command)
    puts "🏠 Dwelling built with ID: #{dwelling_id}"

    # Increase Available Creatures
    increase_creatures_command = Heroes::CreatureRecruitment::IncreaseAvailableCreatures.new(
      dwelling_id,
      creature_id,
      10
    )
    Rails.configuration.command_bus.call(increase_creatures_command)
    puts "👼 Increased available creatures by 10"

    puts "✅ Development seed completed successfully!"
  end
end
