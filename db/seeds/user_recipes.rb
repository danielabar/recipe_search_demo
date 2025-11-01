# db/seeds/user_recipes.rb
#
# Seeds user recipes and their ingredients in chunks
#

puts "Generating #{NUM_USER_RECIPES} user_recipes in chunks of #{CHUNK_SIZE}..."
ingredient_ids = (1..$ingredient_count).to_a
user_recipe_id = 1
chunk_index = 0

# We'll write chunked files: tmp/user_recipes_000.csv and tmp/user_recipe_ingredients_000.csv
while user_recipe_id <= NUM_USER_RECIPES
  stop_id = [ user_recipe_id + CHUNK_SIZE - 1, NUM_USER_RECIPES ].min
  ur_csv = TMP_DIR.join("user_recipes_%03d.csv" % chunk_index)
  uri_csv = TMP_DIR.join("user_recipe_ingredients_%03d.csv" % chunk_index)

  CSV.open(ur_csv, 'w', write_headers: false) do |ur|
    CSV.open(uri_csv, 'w', write_headers: false) do |uri|
      Faker::Config.random = Random.new(400 + chunk_index)
      (user_recipe_id..stop_id).each do |rid|
        uid = 1 + rand(NUM_USERS) # random owner
        title = "#{Faker::Food.dish} with #{Faker::Food.ingredient}"
        created_at = Time.now.utc.iso8601
        # user_recipes columns: user_id, title, created_at
        ur << [ uid, title, created_at ]

        num = 2 + rand(6) # 2..7 ingredients
        ingredient_ids.sample(num).each do |iid|
          uri << [ rid, iid ] # user_recipe_id, ingredient_id
        end
      end
    end
  end

  # COPY chunk files into DB
  copy_file_to_table($pg_conn, absolute(ur_csv), 'user_recipes', [ 'user_id', 'title', 'created_at' ])
  copy_file_to_table($pg_conn, absolute(uri_csv), 'user_recipe_ingredients', [ 'user_recipe_id', 'ingredient_id' ])

  puts "  Loaded user_recipes chunk #{chunk_index} (#{user_recipe_id}-#{stop_id})"

  user_recipe_id = stop_id + 1
  chunk_index += 1
end
