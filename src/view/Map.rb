# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2015 Orthus Technology
# License::   Distributes under the same terms as Ruby


# Represents and manages a character matrix to compose the console output.
class Map


	# Parameters:
	# 
	# +lines+:: number of horizontal lines
	# +chars+:: number of characters per line
	def initialize( lines, chars )
		
		# Initialize instance vars
		@lines = lines
		@line_length = chars

		@ptr = 0			# Pointer for @pages
		@pages = Array.new  # A double array of lines. 1st array represents pages, second lines.

		# Create a blank map of just spaces.
		@blank = String.new 
		(chars * lines).times{ @blank += ' ' }
		post @blank # Post blank

	end


	# Posts new text to the Map. Resets all pages.
	#
	# Parameter:
	# +text+:: text to post to Map
	def post( text )

		# If an object other than String is passed, use the String representation
		text = text.to_s unless text.is_a? String
		# If nothing is passed, use blank
		text = (text == '' or text.is_a? NilClass) ? @blank : text
		# Replace all tabs with 4 spaces
		text.gsub!("\t", '    ')

		# Reset pages and pointer
		@pages = Array.new
		@ptr = 0

		# Local helper stack
		stack = Array.new

		# Separate newlines into an Array
		while !text.empty? 						# Repeat until text is empty

			if !text[/^.*\n/].is_a? NilClass	# If something exists before a newline
				stack.push text[/^.*\n/]		# 	Push that something to the stack
				stack.last.chop!				# 	Chop off the newline
				text.sub!(/^.*\n/, '')			# 	Remove the line from text
			else
				stack.push text 				# Push the remainder to the stack
				text = ''						# Make text empty
			end
		
		end # !text.empty?

		# Separate lines which are over the length of a line
		stack.map!.with_index do |line, i| 		# For each line in the stack

			if line.length > @line_length - 1	# If the current line is greater than the Map line length minus 1 for the boundary
				stack.insert( i+1, line[@line_length-1, line.length] ) # Insert the overflow to its own line
				line[0, @line_length-1]			# Replace current line with substring that fits Map

			else
				line 							# Line doesn't violate length, keep as-is
			end



		end # for each line in stack
 
		# Format each line with newlines at the end
		stack.map!do |line|					# For each line in stack

			"%-#{@line_length-1}s\n" % line 	# Format the line with spaces plus a newline at the end
		end

		# Organize stack lines into pages
		stack.each.with_index do |line, i|		# For each line in stack
			# If new page is needed, make one
			@pages[i / @lines] = Array.new if @pages[i / @lines].is_a? NilClass
			@pages[i / @lines].push line 		# Push line to appropreaite page
		end

		# Grab the remainder of lines that aren't filled on the last page
		remain = @lines - @pages.last.length

		# Push blank lines until last page is full
		remain.times do
			@pages.last.push "%-#{@line_length-1}s\n" % ''
		end

		# Return self
		self

	end # post

	# Takes in text from another Map and sitches the two maps together
	# to a single String for a single page. Uses self's current page.
	# 
	# Parameter:
	# +page+:: Array representation of a Map page or the Map itself. 
	def join( page, image = false )

		# If page is a map, grab the page
		page = page.current_page if page.is_a? Map
		# Check for invalid inputs
		raise ArgumentError, 'Input for join() must be a Map page (Array) or a Map' unless page.is_a? Array
	
		# String to return
		str = String.new

		# For each line in each page, 
		# concat the two lines and replace the first newline with a boundary |
	
		page.each.with_index do |line, i|
			
			break if image and i > 18

			if image and i == 3
				str += @pages[ @ptr ][i].gsub(/\n/, ' ') + line
			else
				str += @pages[ @ptr ][i].gsub(/\n/, "|") + line
			end
		
		end	

		# Return the result
		str

	end # join

	# Returns the page at @ptr
	def current_page
		@pages[ @ptr ]
	end

	# Converts the current page (Array) into a single String
	def to_s
		# String to return
		str = String.new

		# For each line in the current page
		# Concat it to the String to return
		@pages[ @ptr ].each do |line|
			str += line
		end
	
		# Return result
		str

	end # to_s

	# Increments @ptr if legal
	# Returns self
	def next_page
		# Check to make sure @ptr stays in range
		@ptr += 1 if @ptr < @pages.length - 1
		# Return self
		self
	end

	# Decrements @ptr if legal
	# Returns self
	def previous_page
		# Check to make sure @ptr stays in range
		@ptr -= 1 if @ptr > 0
		# Return self
		self
	end

end # Map