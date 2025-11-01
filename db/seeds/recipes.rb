# db/seeds/recipes.rb
#
# Seeds system recipes and their ingredients
#

recipes_csv = TMP_DIR.join('recipes.csv')
recipe_ingredients_csv = TMP_DIR.join('recipe_ingredients.csv')

puts "Generating #{NUM_SYSTEM_RECIPES} system recipes and recipe_ingredients..."
CSV.open(recipes_csv, 'w', write_headers: false) do |rcsv|
  Faker::Config.random = Random.new(222)
  1.upto(NUM_SYSTEM_RECIPES) do |id|
    # Add variety to recipe titles while keeping them recognizable
    base_title = "#{Faker::Food.dish} with #{Faker::Food.ingredient}"

    # Add some variation to avoid duplicates
    variations = [
      base_title,
      "#{Faker::Food.ethnic_category} #{base_title}",
      "#{base_title} and #{Faker::Food.spice}",
      "#{base_title} (#{Faker::Food.measurement} style)",
      "Homemade #{base_title}",
      "Classic #{base_title}",
      "#{base_title} with #{Faker::Food.spice}",
      "#{Faker::Food.description} #{base_title}"
    ]

    # Add a small random hex to guarantee uniqueness
    random_suffix = SecureRandom.hex(2)  # 4 character hex
    title = "#{variations.sample} ##{random_suffix}"
    timestamp = Time.now.utc.iso8601
    rcsv << [ title, timestamp, timestamp ]

    # Show progress every 100 records
    if id % 100 == 0
      print "  #{id}/#{NUM_SYSTEM_RECIPES} recipes generated\r"
      $stdout.flush
    end
  end
  puts "  #{NUM_SYSTEM_RECIPES}/#{NUM_SYSTEM_RECIPES} recipes generated ✓"
end

# Load recipes into database first, so we can query for their IDs
copy_file_to_table($pg_conn, absolute(recipes_csv), 'recipes', [ 'title', 'created_at', 'updated_at' ])

CSV.open(recipe_ingredients_csv, 'w', write_headers: false) do |jcsv|
  # Get actual ingredient IDs from the database
  ingredient_ids = $pg_conn.exec('SELECT id FROM ingredients ORDER BY id').map { |row| row['id'].to_i }
  # Get actual recipe IDs from the database
  recipe_ids = $pg_conn.exec('SELECT id FROM recipes ORDER BY id').map { |row| row['id'].to_i }

  Faker::Config.random = Random.new(333)
  recipe_ids.each_with_index do |recipe_id, index|
    num = 3 + rand(5) # 3..7 ingredients
    ingredient_ids.sample(num).each do |iid|
      timestamp = Time.now.utc.iso8601
      jcsv << [ recipe_id, iid, timestamp, timestamp ]
    end

    # Show progress every 100 records
    if (index + 1) % 100 == 0
      print "  #{index + 1}/#{NUM_SYSTEM_RECIPES} recipe ingredients generated\r"
      $stdout.flush
    end
  end
  puts "  #{NUM_SYSTEM_RECIPES}/#{NUM_SYSTEM_RECIPES} recipe ingredients generated ✓"
end

copy_file_to_table($pg_conn, absolute(recipe_ingredients_csv), 'recipe_ingredients', [ 'recipe_id', 'ingredient_id', 'created_at', 'updated_at' ])
