# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2015 Orthus Technology
# License::   Distributes under the same terms as Ruby 

# Represents an XML name and its roots
class Tag

	# +name+:: String of tag name
	# +value+:: Array of Tag to house children names or String for value if leaf
	# +attributes+:: Hash of any attributes associated with name
	attr_accessor :name, :value, :attributes

	# Parameters:
	# +name+:: tag name
	# +value+:: Array containing child names or value when name is a leaf
	def initialize( name, value = Array.new )

		self.attributes = Hash.new
		self.name = name
		self.value = value
	end

	# Sets new name, extracts attribute information in the form below into a Hash
	# 	TagName[ key=/?('|")value/?('|"), ... ]
	# 
	# Parameter:
	# +name+:: String of tag name with attributes
	def name=( name )

		string = name.slice!(/\s+\w+=.*$/) 	# Remove the attribute section
		@name = name 							# Set name name

		return if string.is_a? NilClass		# Return if no attribute information present

		string.slice!(0)					# Remove the first space
		attrs = string.split(/\s+/)			# Split multiple attributes
		
		# For each attribute string
		attrs.each do |str|
			val = str[/\\?("|').*\\?("|')/].gsub(/\\?("|')/, '') # Extract value section
			self.attributes[ str[/^\w*/] ] = val 				 # Add attribute to hash
		end

	end # name=

	# Sets value. If Tag, appends it to the array.
	#
	# Parameter:
	# +value+:: String, Array, or Tag to act as Tag value
	#
	# Raises:
	# ArgumentError:: Iputs that aren't either String, Array, or Tag
	def value=( value )

		case value
		when String, Array  # Leaf value or Array of children Tags
			@value = value
		when Tag 			# Single child to be added
			@value.push value
		else
			raise ArgumentError, "#{value.class} is not a valid type for Tag.value."
		end

	end # value=

	# Finds Tags which match input param.
	# 
	# Parameters:
	# +name+:: Name of name you'd like to find
	#
	# Returns:
	# +nil+ if search fails
	# +String+ of Tag value if only one Tag matched
	# +Array+ of Tags if multiple matches found
	def []( name )
		result = self.find_name name

		if result.empty?
			nil
		elsif result.size == 1
			result.last.value
		else
			result
		end
	end

	# Finds Tags which match input param.
	# 
	# Parameters:
	# +name+:: Name of name you'd like to find
	# +matches+:: Array of matched Tags. Used for recusion. Leave blank.
	#
	# Returns:
	# +Array+ of Tags with matching name names
	def find_name( name, matches = Array.new )
		
		# If current name is a match
		# Add it to array
		matches.push self if self.name == name
	
		# Call this method for all children
		if !self.is_leaf?
			self.value.each do |child|
				child.find_name( name, matches )
			end
		end

		return matches

	end # find_name

	# Returns:
	# +boolean+ false if value is a Array, true if not
	def is_leaf?
		if @value.is_a? Array
			false
		else
			true
		end		
	end


	# Returns a string representation of name and children
	# 
	# Parameter:
	# +space+:: Used recursively by method. Leave empty. 
	def to_s( space = '' )

		this = "#{space}[#{@name}] #{@value}"

		if self.is_leaf?
			"#{space}[#{@name}] #{@value}"
		else
			this = "#{space}[#{@name}]"
			@value.each{ |child| this += "\n#{child.to_s( space + '|  ')}" }
		end

		this
	end

end

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
		input = input.split(/<(.+?)>/)  # Chop up names/value

		stack = Array.new				# Stack to work for PDA
		stack.push Tag.new( 'ROOT' ) 	# Add ROOT Tag

		input.each_cons(3) do | before, element, after |
			
			# If element is value
			if '/' + before == after
				# Add that value to the parent's value variable
				stack.last.value = element

			# Else if element is a name
			elsif element != ''

				# If name is an end-name
				if element[0] == '/'
					# Pop parent off the stack
					stack.pop
				else # name is new name
					name = Tag.new( element ) 	# Create name
					stack.last.value = name 		# Add name to parent value variable
					stack.push name 				# Push current name to stack
				end
			end	
		end # loop

		stack.pop if input.last[0] == '/' # Clean up last element (loop doesn't reach)
		stack.last # return the root

	end # parse

end # XML