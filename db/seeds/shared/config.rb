# db/seeds/shared/config.rb
#
# Shared configuration for recipe_search_demo seeding
#
require 'csv'
require 'faker'
require 'pg'

# ---------- CONFIG ----------
NUM_USERS        = (ENV['SEED_USERS'] || 10_000).to_i
NUM_SYSTEM_RECIPES = (ENV['SEED_SYSTEM_RECIPES'] || 10_000).to_i
NUM_USER_RECIPES = (ENV['SEED_USER_RECIPES'] || 1_500_000).to_i
INGREDIENTS_FROM_USDA = File.exist?(Rails.root.join('db', 'seed_data', 'ingredients_usda.csv'))
INGREDIENTS_COUNT = (ENV['SEED_INGREDIENTS'] || 400).to_i # used only if USDA not present
CHUNK_SIZE       = (ENV['SEED_CHUNK'] || 100_000).to_i    # chunk size for user_recipes generation and COPY
TMP_DIR          = Rails.root.join('tmp', 'seeds')
SEED_DATA_DIR    = Rails.root.join('db', 'seed_data')
# ----------------------------

FileUtils.mkdir_p(TMP_DIR)
FileUtils.mkdir_p(SEED_DATA_DIR)

puts "Seeding with:"
puts "  users = #{NUM_USERS}"
puts "  system recipes = #{NUM_SYSTEM_RECIPES}"
puts "  user recipes = #{NUM_USER_RECIPES}"
puts "  chunk size = #{CHUNK_SIZE}"
puts "  tmp dir = #{TMP_DIR}"
puts "  using USDA? #{INGREDIENTS_FROM_USDA}"

# Connect to postgres via PG for COPY streaming
db_conf = ActiveRecord::Base.connection_db_config.configuration_hash
pg_conn_params = {}
pg_conn_params[:host] = db_conf[:host] if db_conf[:host]
pg_conn_params[:port] = db_conf[:port] if db_conf[:port]
pg_conn_params[:dbname] = db_conf[:database] || db_conf[:dbname]
pg_conn_params[:user] = db_conf[:username] || db_conf[:user]
pg_conn_params[:password] = db_conf[:password] if db_conf[:password]

$pg_conn = PG.connect(pg_conn_params)
