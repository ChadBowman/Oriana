# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2015 Orthus Technology
# License::   Distributes under the same terms as Ruby 

require_relative 'Tag'

# A class for housing and manipulating XML strings
class XML

	# Root Tag class
	attr_accessor :root

	# Parameter:
	# +root+:: The root Tag or raw XML String
	def initialize( root )
		self.root = root
	end

	# Sets a new root Tag or parses one if XML String
	#
	# Parameter:
	# +root+:: Raw XML String or Tag.
	def root=( root )
		
		case root
		when String # If String, parse it, baby!
			@root = parse root
		when Tag
			@root = root
		else
			raise ArgumentError, "#{root.class} is not a valid input for XML."
		end
	end

	# Search for specific Tag in XML. 
	#
	# Parameters: 
	# +name+:: Name of name to find
	#
	# Returns:
	# +nil+ if search unsucessful
	# +String+ value if only one Tag matched
	# +Array+ of Tag if more than one matched
	def []( name )

		# Query root
		result = @root.find_name name

		if result.empty?
			nil
		elsif result.size == 1 # Only one match found
			result.last.value
		else
			result
		end
	end # []

	def to_s
		@root.to_s
	end

	def parse( input )

		input.slice!(/<\?.*\?>/)		# Remove XML header
		input.gsub!(/\n\s*/, '')		# Remove newlines and whitespace
		input.gsub!('&quot;', "\"")		# Return quotes
		input = input.split(/<(.+?)>/)  # Chop up names/value

		stack = Array.new				# Stack to work for PDA
		stack.push Tag.new( 'ROOT' ) 	# Add ROOT Tag

		input.each_cons(3) do | before, element, after |
			
			# Deal with single tags e.g. <ASingleTag/>
			if element[-1] == '/'
				name = Tag.new element.chop
				stack.last.value = name

			# If element is value
			elsif '/' + before == after
				# Add that value to the parent's value variable
				stack.last.value = element

			# Else if element is a name
			elsif element != ''

				# If name is an end-name
				if element[0] == '/'
					# Pop parent off the stack
					stack.pop
				else # name is new name
					name = Tag.new element  	# Create name
					stack.last.value = name 	# Add name to parent value variable
					stack.push name 			# Push current name to stack
				end
			end	
		end # loop

		stack.pop if input.last[0] == '/' # Clean up last element (loop doesn't reach)
		stack.last # return the root

	end # parse

end # XML