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
    title = "#{Faker::Food.dish} with #{Faker::Food.ingredient}"
    created_at = Time.now.utc.iso8601
    rcsv << [ title, created_at ]
  end
end

CSV.open(recipe_ingredients_csv, 'w', write_headers: false) do |jcsv|
  # ingredient ids are assumed 1..$ingredient_count
  ingredient_ids = (1..$ingredient_count).to_a
  Faker::Config.random = Random.new(333)
  1.upto(NUM_SYSTEM_RECIPES) do |rid|
    num = 3 + rand(5) # 3..7 ingredients
    ingredient_ids.sample(num).each do |iid|
      jcsv << [ rid, iid ]
    end
  end
end

copy_file_to_table($pg_conn, absolute(recipes_csv), 'recipes', [ 'title', 'created_at' ])
copy_file_to_table($pg_conn, absolute(recipe_ingredients_csv), 'recipe_ingredients', [ 'recipe_id', 'ingredient_id' ])
