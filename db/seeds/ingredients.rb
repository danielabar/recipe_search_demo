# db/seeds/ingredients.rb
#
# Seeds ingredients table from USDA data or generates fake data
#

ingredients_csv = SEED_DATA_DIR.join('ingredients_load.csv')
if INGREDIENTS_FROM_USDA
  puts "Using USDA CSV at db/seed_data/ingredients_usda.csv"
  usda_path = SEED_DATA_DIR.join('ingredients_usda.csv')
  # We expect USDA csv has header and 'description' column; adapt if needed
  CSV.open(ingredients_csv, 'w', write_headers: false) do |out|
    CSV.foreach(usda_path, headers: true) do |row|
      desc = row['description'] || row['Description'] || row['description'.to_sym]
      next if desc.nil? || desc.strip.empty?
      out << [ desc.strip ]
    end
  end
else
  puts "USDA file not found; synthesizing #{INGREDIENTS_COUNT} ingredient names via Faker"
  seen = {}
  CSV.open(ingredients_csv, 'w', write_headers: false) do |csv|
    Faker::Config.random = Random.new(42)
    while seen.size < INGREDIENTS_COUNT
      n = Faker::Food.ingredient.strip
      next if n.empty?
      next if seen[n.downcase]
      seen[n.downcase] = true
      csv << [ n ]
    end
  end
end

# COPY ingredients
copy_file_to_table($pg_conn, absolute(ingredients_csv), 'ingredients', [ 'name' ])

# get ingredient count and IDs (assume serial IDs start at 1)
$ingredient_count = ActiveRecord::Base.connection.select_value('SELECT count(*) FROM ingredients').to_i
puts "Loaded ingredients: #{$ingredient_count}"
