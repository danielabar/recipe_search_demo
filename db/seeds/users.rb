# db/seeds/users.rb
#
# Seeds users table with fake user data
#

users_csv = TMP_DIR.join('users.csv')

if File.exist?(users_csv)
  puts "Using existing users CSV (#{NUM_USERS})..."
else
  puts "Generating users CSV (#{NUM_USERS})..."
  CSV.open(users_csv, 'w', write_headers: false) do |csv|
    Faker::Config.random = Random.new(123)
    1.upto(NUM_USERS) do |i|
      email_address = Faker::Internet.unique.email
      # Use lowest cost (4) for development seeds performance since we need a lot of users
      # Higher cost makes seeding way too slow for development purposes
      password_digest = BCrypt::Password.create('Password123!', cost: 4)
      timestamp = Time.now.utc.iso8601
      csv << [ email_address, password_digest, timestamp, timestamp ]

      # Show progress every 100 records
      if i % 100 == 0
        print "  #{i}/#{NUM_USERS} users generated\r"
        $stdout.flush
      end
    end
    puts "  #{NUM_USERS}/#{NUM_USERS} users generated ✓"
  end
end

# COPY users: expecting columns email_address,password_digest,created_at,updated_at
copy_file_to_table($pg_conn, absolute(users_csv), 'users', [ 'email_address', 'password_digest', 'created_at', 'updated_at' ])
