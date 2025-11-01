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

puts "Seeding system recipes..."
load Rails.root.join("db/seeds/recipes.rb")
puts "✅ System recipes seeded."

puts "Seeding user recipes..."
load Rails.root.join("db/seeds/user_recipes.rb")
puts "✅ User recipes seeded."

puts "🎉 Recipe search demo seeding completed!"
