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

	# Returns array of variables split by spaces. _ are repalced with space.
	# 
	# Parameter:
	# +command+:: command to be removed from string prior to variable extraction.
	def get_vars( command = nil )
		# Remove command and split by space.
		if command.is_a? NilClass
			vars = self.value.split(' ')
		else
			vars = self.value.sub( "#{command} ", '' ).split(' ')
		end

		# Replace underscores with spaces
		vars.map! do |element|
			element.gsub('_', ' ')
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
		replace "#{@lines}.0", "#{@lines}.#{@bound}", text
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

class Map

	def initialize( lines, chars )
		
		@line_length = chars
		@lines = lines

		@ptr = 0
		@pages = Array.new

		@blank = String.new
		(chars * lines).times{ @blank += ' ' }
		post @blank

	end

	def post( text )

		retain = text
		text = (text == '' or text.is_a? NilClass) ? @blank : text
		text.gsub!("\t", '    ')

		@pages = Array.new # Reset pages
		stack = Array.new

		# Separate newlines
		while !text.empty?

			if text[/^.*\n/] != nil
				stack.push text[/^.*\n/]
				stack.last.chop!
				text.sub!(/^.*\n/, '')
			else
				stack.push text
				text = ''
			end
		
		end

		# Separate lines over char length
		stack.map!.with_index do |line, i|

			if line.length > @line_length - 1
				stack.insert i+1, line[@line_length-1, line.length]
				line[0, @line_length-1]
			else
				line
			end
		end
 
		# Format with newlines
		stack.map! do |line|
			"%-#{@line_length-1}s\n" % line
		end

		stack.each.with_index do |line, i|
			@pages[i / @lines] = Array.new if @pages[i / @lines].is_a? NilClass
			@pages[i / @lines].push line
		end

		remain = @lines - @pages.last.length

		remain.times do
			@pages.last.push "%-#{@line_length-1}s\n" % ''
		end

		self
	end

	def join( page )

		page = page.current_page if page.is_a? Map

		str = String.new

		page.each.with_index do |line, i|
			str += @pages[ @ptr ][i].gsub(/\n/, '|') + line
		end	

		str
	end

	def current_page
		@pages[ @ptr ]
	end

	def to_s
		str = String.new
		if !@pages[ @ptr ].is_a? NilClass
			@pages[ @ptr ].each do |line|
				str += line
			end
		end

		str
	end

	def next_page
		@ptr += 1 if @ptr < @pages.length - 1
		self
	end

	def previous_page
		@ptr -= 1 if @ptr > 0
		self
	end
end