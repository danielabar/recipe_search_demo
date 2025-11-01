# db/seeds/maintenance.rb
#
# Post-seeding maintenance tasks
#

puts "Running VACUUM ANALYZE to update stats..."
ActiveRecord::Base.connection.execute("VACUUM ANALYZE users;")
ActiveRecord::Base.connection.execute("VACUUM ANALYZE recipes;")
ActiveRecord::Base.connection.execute("VACUUM ANALYZE user_recipes;")
ActiveRecord::Base.connection.execute("VACUUM ANALYZE ingredients;")
ActiveRecord::Base.connection.execute("VACUUM ANALYZE recipe_ingredients;")
ActiveRecord::Base.connection.execute("VACUUM ANALYZE user_recipe_ingredients;")

puts "Seeding complete ✅"
$pg_conn.close
