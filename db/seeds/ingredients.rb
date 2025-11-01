# db/seeds/ingredients.rb
#
# Seeds ingredients table from USDA data or generates fake data
#

ingredients_csv = TMP_DIR.join('ingredients.csv')

# Always generate fresh CSV file, replacing existing one if necessary
if INGREDIENTS_FROM_USDA
  puts "Generating fresh ingredients CSV from USDA data at db/seed_data/ingredients_usda.csv"
  usda_path = SEED_DATA_DIR.join('ingredients_usda.csv')
  # We expect USDA csv has header and 'description' column; adapt if needed
  timestamp = Time.now.utc.iso8601
  CSV.open(ingredients_csv, 'w', write_headers: false) do |out|
    CSV.foreach(usda_path, headers: true) do |row|
      desc = row['description'] || row['Description'] || row['description'.to_sym]
      next if desc.nil? || desc.strip.empty?
      out << [ desc.strip, timestamp, timestamp ]
    end
  end
else
  raise "USDA ingredients file not found at db/seed_data/ingredients_usda.csv. Please provide the USDA data file to seed ingredients."
end

# COPY ingredients: expecting columns name,created_at,updated_at
copy_file_to_table($pg_conn, absolute(ingredients_csv), 'ingredients', [ 'name', 'created_at', 'updated_at' ])

# get ingredient count and IDs (assume serial IDs start at 1)
$ingredient_count = ActiveRecord::Base.connection.select_value('SELECT count(*) FROM ingredients').to_i
puts "Loaded ingredients: #{$ingredient_count}"
