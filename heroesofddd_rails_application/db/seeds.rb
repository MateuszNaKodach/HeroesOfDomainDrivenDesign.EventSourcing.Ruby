# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require "building_blocks/application/app_context"

game_id = "fcc8f601-76cb-4b5a-972d-b7431303f69a"
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
dwelling_id = "cecc4307-e940-4ef2-8436-80c475729938"
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
