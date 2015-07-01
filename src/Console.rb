# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2015 Orthus Technology
# License::   Distributes under the same terms as Ruby

require 'tk'

# Command-line terminal++
class Console

	# +root+:: Tk::Root pane of Console
	# +input+:: Tk::Entry to handle normal user input
	# +output+:: Tk::Text to handle dynamic, user output
	# +history+:: Array of previous user commands
	attr_reader :root, :in, :out, :history

	# +height+:: height of output in lines
	# +width+:: width of output in characters
	# +title+:: title of window
	def initialize( height = 30, width = 100, title = 'Console' )
		
		# Mono-spaced font for output
		mono = TkFont.new( 'family' => 'Consolas', 'size' => 14 )
		# Jura for input
		jura = TkFont.new( 'family' => 'Jura', 'size' => 15 )

		# Root pane
		@root = Tk::Root.new do 
			title title
		end

		# Text window output
		@out = TextManager.new( @root, height, width ) do 
			font mono
			height height
			width width
			pack
		end

		# Text entry input
		@in = Tk::Entry.new( @root ) do 
			font jura	
			pack( side: 'bottom', fill: 'x' )
			focus
		end

		# Centers window
		# TODO make this work for any window size
		@root.geometry '+150+60'

		# Stack of call history
		@history = Array.new
		# Call history pointer
		place = -1

		# Input capture
		@in.bind('Return') do
			@history.push @in.get
			place = @history.length
			@in.delete 0, 'end'
			yield Input.new( @history.last ), @out if block_given?
		end

		# History access
		@in.bind('Up') do
			if place > 0
				place -= 1
				@in.delete 0, 'end'
				@in.insert 0, @history[place]
			end
		end

		# History return access
		@in.bind('Down') do
			if place < @history.length - 1
				place += 1
				@in.delete 0, 'end'
				@in.insert 0, @history[place]
			end
		end

		# Next page
		@in.bind('Right') do
			@out.next
		end

		# Previous page
		@in.bind('Left') do
			@out.previous
		end

		# Next page (sub pane)
		@in.bind('Shift-Right') do
			@out.next_sub
		end

		# Previous page (sub pane)
		@in.bind('Shift-Left') do
			@out.previous_sub
		end

	end # initialize

	# Run the main_pane loop, start the window
	def start() @root.mainloop end

end # Console

# Wraps and handles formatting of input string
class Input

	# +value+:: input string to console
	attr_accessor :value

	# Parameter:
	# +value+:: string input to console
	def initialize( value )
		self.value = value
	end

	# Returns hash with flags as keys and arguments as values
	# 	-f argument >> f => arugment
	# 
	# Parameter:
	# +command+:: command to remove from argument
	def get_flags( command = nil )
		# Remove command, split by spaces
		if command.is_a? NilClass
			vars = self.value.split ' '
		else
			vars = self.value.sub( /#{command} ?/, '' ).split ' '
		end

		# Hash to return
		flags = Hash.new
		# for each pair of arugments, place in Hash
		# 	flags[ flag ] = argument
		vars.each_cons(2) do |this, nxt|
			# If first element is a valid flag
			if this =~ /^-\S+/ 
				# Replace underscores
				value = nxt.gsub('_', ' ')
				# parse true/false values
				value = true if value.include? 'yes' or value.include? 'true'
				value = false if value.include? 'no' or value.include? 'false'

				flags[ this.sub('-', '') ] = value
			end
		end		

		# Return result
		flags

	end # get_flags

	# Returns array of variables split by spaces. _ are repalced with space.
	# 
	# Parameter:
	# +command+:: command to be removed from string prior to variable extraction.
	def get_vars( command = nil )
		# Remove command and split by space.
		if command.is_a? NilClass
			# No command, so just split
			vars = self.value.split ' '
		else
			vars = self.value.sub( /#{command} ?/, '' ).split ' '
		end

		vars.map! do |element|
			# Replace underscores
			element.gsub!('_', ' ')
			# Parse true/false values
			element = true if element.include? 'yes' or element.include? 'true'
			element = false if element.include? 'no' or element.include? 'false'
			# Return to map
			element
		end
		
		# Return element if only 1 exists, else the array
		vars = vars.length == 1 ? vars.first : vars

	end # get_vars

end # Input

# Manages output by keeping every like consistent in regards to newlines 
# at the end of each line, only +lines+ number of lines, etc by using Map.
class TextManager < Tk::Text

	# Parameters:
	# +parent+:: root pane
	# +lines+:: number of horizontal lines
	# +characters+:: number of characters each line should have
	# +boundary+:: Proportion of length to separate the Main pane from the Sub pane. Default is 0.66 (69%).
	def initialize( parent, lines, characters, boundary = 0.69 )
		super parent

		# Number of lines
		@lines = lines
		# Character to draw boundary at
		@bound = Integer( boundary * characters )

		# Pane initialization
		@main_pane = Map.new( lines - 3, @bound )
		@sub_pane = Map.new( lines - 3, characters - @bound )

	end # initialize

	##### POST CONTENT

	# Posts text on very bottom of output
	#
	# Parameter:
	# +text+:: text to place at prompt location. Newlines are repalced with space.
	def prompt( text )
		text.gsub!("\n", ' ')
		replace "#{@lines}.0", "#{@lines}.end", text
	end

	# Posts text in Main pane
	#
	# Parameter:
	# +text+:: text to replace on the Main pane.
	def post( text )
		replace '2.0', "#{@lines - 1}.end", @main_pane.post( text ).join( @sub_pane.current_page )
	end

	# Posts text in Sub pane
	#
	# Parameter:
	# +text+:: text to replace on the Sub pane.
	def post_sub( text )
		replace '2.0', "#{@lines - 1}.end", @main_pane.join( @sub_pane.post( text ) )
	end

	# Posts text in both panes
	#
	# Parameter:
	# +main+:: text to replace on the Main pane.
	# +sub+:: text to replace on the Sub pane.
	def post_both( main, sub )
		replace '2.0', "#{@lines - 1}.end", @main_pane.post( main ).join( @sub_pane.post( sub ) )		
	end

	##### NAVIGATION

	# Displays the next page for the Main pane, if it exists.
	def next
		replace '2.0', "#{@lines - 1}.end", @main_pane.next_page.join( @sub_pane.current_page )
	end

	# Displays the next page for the Sub pane, if it exists.
	def next_sub
		replace '2.0', "#{@lines - 1}.end", @main_pane.join( @sub_pane.next_page )
	end

	# Displays the previous page for the Main pane, if it exists.
	def previous
		replace '2.0', "#{@lines - 1}.end", @main_pane.previous_page.join( @sub_pane.current_page )
	end

	# Displays the previous page for the Sub pane, if it exists.
	def previous_sub
		replace '2.0', "#{@lines - 1}.end", @main_pane.join( @sub_pane.previous_page )
	end

end # TextManager

# Represents and manages a character matrix to fill the console.
class Map

	# Parameters:
	# 
	# +lines+:: number of horizontal lines
	# +chars+:: number of characters per line
	def initialize( lines, chars )
		
		# Initialize instance vars
		@line_length = chars
		@lines = lines

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

		# Reset pages
		@pages = Array.new

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
				stack.insert i+1, line[@line_length-1, line.length] # Insert the overflow to its own line
				line[0, @line_length-1]			# Replace current line with substring that fits Map
			else
				line 							# Line doesn't violate length, keep as-is
			end

		end # for each line in stack
 
		# Format each line with newlines at the end
		stack.map! do |line|					# For each line in stack
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
	def join( page )

		# If page is a map, grab the page
		page = page.current_page if page.is_a? Map
		# Check for invalid inputs
		raise ArgumentError, 'Input for join() must be a Map page (Array) or a Map' unless page.is_a? Array
	
		# String to return
		str = String.new

		# For each line in each page, 
		# concat the two lines and replace the first newline with a boundary |
		page.each.with_index do |line, i|
			str += @pages[ @ptr ][i].gsub(/\n/, '|') + line
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