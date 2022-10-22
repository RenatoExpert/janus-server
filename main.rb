
def create_table (name, *columns)
  columns.length > 0 ||  columns = ['id int', 'name varchar(255)']
  $db.execute <<~SQL
    CREATE TABLE IF NOT EXISTS #{name}(
      #{columns.join(',')}
    );
  SQL
end

def insert_row (table, *values)
  asks = []
  for i in 0...values.length
    asks.push('?')
  end
  $db.execute "INSERT INTO #{table} VALUES (#{asks.join(', ')})", values
end

BEGIN {
  # Setup Gems
  system 'gem install bundler --conservative'
  system('bundle check') || system('bundle install')

  # Setup tcp socket
  require 'socket'
  server = TCPServer.new 2000

  # Setup database
  require 'sqlite3'
  system('mkdir -p db')
  system('touch db/database.db')
  $db = SQLite3::Database.open "db/database.db"
}

create_table 'slaves', 'huuid', 'tagname', 'curIP', 'GPIO_Status'
create_table 'logs', 'id', 'timestamp', 'priority', 'message'
insert_row 'logs', 'josh', 'bet', 'jaman', 'rick'

END {
  loop do
    Thread.start(server.accept) do |client|
      puts client.gets
      client.puts "Hello !"
      client.close
    end
  end
}

