# db/seeds.rb
#
# Main orchestrator for recipe_search_demo seeding
#
puts "🌱 Starting recipe search demo seeding..."

# Load shared configuration and utilities
load Rails.root.join("db/seeds/shared/config.rb")
load Rails.root.join("db/seeds/shared/utilities.rb")

puts "Seeding users..."
load Rails.root.join("db/seeds/users.rb")
puts "✅ Users seeded."

puts "Seeding ingredients..."
load Rails.root.join("db/seeds/ingredients.rb")
puts "✅ Ingredients seeded."

# WIP on next seeding steps...
puts "Seeding system recipes..."
load Rails.root.join("db/seeds/recipes.rb")
puts "✅ System recipes seeded."

# puts "Seeding user recipes..."
# load Rails.root.join("db/seeds/user_recipes.rb")
# puts "✅ User recipes seeded."

# puts "Running post-load maintenance..."
# load Rails.root.join("db/seeds/maintenance.rb")
# puts "✅ Maintenance completed."

# puts "🎉 Recipe search demo seeding completed!"
