# db/seeds/shared/utilities.rb
#
# Shared utility functions for seeding
#

# ----------- Helper utilities -----------
def copy_file_to_table(pg_conn, file_path, table_name, columns)
  # file_path - absolute path
  raise "File not found: #{file_path}" unless File.exist?(file_path)
  sql = "COPY #{table_name} (#{columns.join(',')}) FROM STDIN WITH (FORMAT csv)"
  puts "COPY -> #{table_name} (#{File.basename(file_path)})"
  pg_conn.copy_data(sql) do
    File.foreach(file_path) do |line|
      pg_conn.put_copy_data(line)
    end
  end
  # NOTE: copy_data automatically sends end after the block
  puts "  done #{table_name}"
end

def absolute(path)
  Pathname.new(path).expand_path.to_s
end
