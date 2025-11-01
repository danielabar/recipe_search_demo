# db/seeds/user_recipes.rb
#
# Seeds user recipes and their ingredients in chunks
#

puts "Generating #{NUM_USER_RECIPES} user_recipes in chunks of #{CHUNK_SIZE}..."
# Get actual ingredient IDs from the database
ingredient_ids = $pg_conn.exec('SELECT id FROM ingredients ORDER BY id').map { |row| row['id'].to_i }
# Get actual user IDs from the database
user_ids = $pg_conn.exec('SELECT id FROM users ORDER BY id').map { |row| row['id'].to_i }
user_recipe_id = 1
chunk_index = 0

# We'll write chunked files: tmp/user_recipes_000.csv and tmp/user_recipe_ingredients_000.csv
while user_recipe_id <= NUM_USER_RECIPES
  stop_id = [ user_recipe_id + CHUNK_SIZE - 1, NUM_USER_RECIPES ].min
  ur_csv = TMP_DIR.join("user_recipes_%03d.csv" % chunk_index)
  uri_csv = TMP_DIR.join("user_recipe_ingredients_%03d.csv" % chunk_index)

  CSV.open(ur_csv, 'w', write_headers: false) do |ur|
    Faker::Config.random = Random.new(400 + chunk_index)
    (user_recipe_id..stop_id).each_with_index do |rid, index|
      uid = user_ids.sample # random owner from actual user IDs
      base_title = "#{Faker::Food.dish} with #{Faker::Food.ingredient}"
      # Add a small random hex to guarantee uniqueness
      random_suffix = SecureRandom.hex(2)  # 4 character hex
      title = "#{base_title} ##{random_suffix}"
      timestamp = Time.now.utc.iso8601
      # user_recipes columns: user_id, title, created_at, updated_at
      ur << [ uid, title, timestamp, timestamp ]

      # Show progress every 1000 records
      if (index + 1) % 1000 == 0
        current_count = user_recipe_id + index
        print "  #{current_count}/#{NUM_USER_RECIPES} user recipes generated\r"
        $stdout.flush
      end
    end
  end

  # COPY user_recipes chunk into DB first
  copy_file_to_table($pg_conn, absolute(ur_csv), 'user_recipes', [ 'user_id', 'title', 'created_at', 'updated_at' ])

  # Get the count of records we just inserted
  records_inserted = stop_id - user_recipe_id + 1

  # Get the actual user_recipe IDs that were just inserted (the most recent ones)
  actual_user_recipe_ids = $pg_conn.exec("SELECT id FROM user_recipes ORDER BY id DESC LIMIT #{records_inserted}").map { |row| row['id'].to_i }.reverse

  CSV.open(uri_csv, 'w', write_headers: false) do |uri|
    Faker::Config.random = Random.new(400 + chunk_index)
    actual_user_recipe_ids.each_with_index do |actual_rid, index|
      num = 2 + rand(6) # 2..7 ingredients
      selected_ingredient_ids = ingredient_ids.sample(num).uniq # ensure uniqueness
      selected_ingredient_ids.each do |iid|
        timestamp = Time.now.utc.iso8601
        uri << [ actual_rid, iid, timestamp, timestamp ] # user_recipe_id, ingredient_id, created_at, updated_at
      end

      # Show progress every 1000 records
      if (index + 1) % 1000 == 0
        current_count = user_recipe_id + index
        print "  #{current_count}/#{NUM_USER_RECIPES} user recipe ingredients generated\r"
        $stdout.flush
      end
    end
  end

  # COPY user_recipe_ingredients chunk into DB
  copy_file_to_table($pg_conn, absolute(uri_csv), 'user_recipe_ingredients', [ 'user_recipe_id', 'ingredient_id', 'created_at', 'updated_at' ])

  puts "  Loaded user_recipes chunk #{chunk_index} (#{user_recipe_id}-#{stop_id})"

  user_recipe_id = stop_id + 1
  chunk_index += 1
end
