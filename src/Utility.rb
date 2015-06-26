module C

	VERSION = '1.0'

	WELCOME = <<-END 
		\n\n\n\n\n\n\n\n\n\n
				   Orthus Technology
				   _____   ______ _____ _______ __   _ _______
				  |     | |_____/   |   |_____| | \\  | |_____|
				  |_____| |    \\_ __|__ |     | |  \\_| |     |
					
    	 		   	        			         Version: #{VERSION}
    	\n\n\n\n\n\n\n\n\n\n\n\n\n
		END
end


class Date

	attr_accessor :value

	def initialize( date )
		self.value = date
	end

	def year
		@value[/^\d+-/].sub('-', '')
	end

end

class Session

	attr_accessor 	:profile,
					:inventory, 
					:color_lists, 
					:quality_lists

	def initialize
		self.color_lists = Hash.new
		self.quality_lists = Hash.new
		self.inventory = Inventory.new
		
	end

	def color_list_to_s( name )
		str = "#{name}: "
		@color_lists[name].each do |value|
			str += "#{value},"
		end
		str.chop!

	end

	def quality_list_to_s( name )
		str = "#{name}: "
		@quality_lists[name].each do |value|
			str += "#{value},"
		end
		str.chop!

	end

end

class Profile

	attr_accessor :production, :token 

	def initialize( production, token )
		self.production = production
		self.token = token
	end

end
