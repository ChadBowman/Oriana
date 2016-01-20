

require 'mysql2'


class Database


	attr_reader :config


	def initialize( host, username, password, database, port = 3306 )
		
		@config = {
			host: host,
			username: username,
			password: password,
			database: database, 
			port: port
		}

		connect

	end


	def query( request )

		@conn.query( request, :symbolize_keys => true ) unless @conn.nil?

	end

	def connect

		@conn = Mysql2::Client.new( @config )

	end

	def close
		@conn.close
		
	end

end