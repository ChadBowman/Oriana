# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2015 Orthus Technology
# License::   Distributes under the same terms as Ruby

require 'tk'
require_relative 'Map'

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
		wrap :none

		# Number of lines
		@lines = lines
		@characters = characters

		# Character to draw boundary at
		@bound = Integer( boundary * characters )

		# Pane initialization
		@main_pane = Map.new( lines - 2, @bound )
		@sub_pane = Map.new( lines - 2, characters - @bound )
		
		

	end # initialize

	def thinking

		@wheel = Thread.new do
			while true
				prompt_right ' >.< '
				sleep 0.2
				prompt_right '.< >.'
				sleep 0.2
			end
		end
	end

	def done_thinking
		@wheel.kill
		prompt_right '     '
	end


	##### POST CONTENT
	def top( text )
		text.gsub!("\n", ' ')
		replace( '1.0', '1.120', text )
	end

	# Posts text on very bottom of output
	#
	# Parameter:
	# +text+:: text to place at prompt location. Newlines are repalced with space.
	def prompt( text )
		text.gsub!("\n", ' ')
		replace( "#{@lines}.0", "#{@lines}.120", text )
	end

	def prompt_right( text )
		line = get("#{@lines}.0", "#{@lines}.end")[/\w.*/]
		line = '' if line.nil?
		
		while line.length != 115
			if line.length < 115			
				line = line + ' '
			else
				line = line[0, line.length - 1]
			end
		end
		
		replace( "#{@lines}.0", "#{@lines}.end", line + text )
	end


	# Posts text in Main pane.
	#
	# Parameter:
	# +text+:: text to replace on the Main pane.
	def post( text, image = nil )

		replace( '2.0', "#{@lines - 1}.end", 
			@main_pane.post( text ).join( @sub_pane.current_page, !image.nil? ) )

		unless image.nil?

			add_tag('img', '5.10')
			if image.fmt == 'gif'
				TkTextImage.new( self, 'img.first', image: image.to_tk )
			else
				im = image.to_gif
				im = im.to_tk
				TkTextImage.new( self, 'img.first', image: im )
			end
		end
	end

	# Posts text in the center of the Main pane.
	def center( text )
		text = add_tab text
		padding = (@lines - lines_of_text( text )) / 2

		t = ''
		padding.times{ t += "\n" } 
		text = t + text

		replace( "2.0", "#{@lines - 1}.end", 
			@main_pane.post( text ).join( @sub_pane.current_page ) )
	end

	def add_tab( text )

		rows = text.split "\n"

		output = ''
		rows.each do |row|
			output += "    #{row}\n" 
		end
		
		output

	end

	def splash( text )
		6.times{ text = add_tab( text ) }
	
		text.gsub!("\t", '    ')
		splash_img = ''
		img = text.split "\n"
		delay = (@lines - img.size) / 2
		i = 1
		k = 0
		(@lines - 1).times do
			j = 0 
			if i < delay
				@characters.times{ splash_img += ' ' }
				splash_img.chop!
				splash_img += "\n"

			elsif i < delay + img.size

				@characters.times do
					
					if j < img[k].length
						splash_img += img[k][j]

					else
						splash_img += ' '

					end
					j += 1
				end
				splash_img.chop!
				splash_img += "\n"
				k += 1
			else

				@characters.times{ splash_img += ' ' }
				splash_img.chop!
				splash_img += "\n"
			end

			i += 1

		end


		
		insert( '1.0', splash_img )
	end

	# Posts text in Sub pane
	#
	# Parameter:
	# +text+:: text to replace on the Sub pane.
	def post_sub( text )
		replace( '2.0', "#{@lines - 1}.end", 
			@main_pane.join( @sub_pane.post( text ) ) )
	end

	# Posts text in both panes
	#
	# Parameter:
	# +main+:: text to replace on the Main pane.
	# +sub+:: text to replace on the Sub pane.
	def post_both( main, sub )
		replace( '2.0', "#{@lines - 1}.end", 
			@main_pane.post( main ).join( @sub_pane.post( sub ) ) )	
	end

	##### NAVIGATION

	# Displays the next page for the Main pane, if it exists.
	def next
		replace( '2.0', "#{@lines - 1}.end", 
			@main_pane.next_page.join( @sub_pane.current_page ) )
	end

	# Displays the next page for the Sub pane, if it exists.
	def next_sub
		replace( '2.0', "#{@lines - 1}.end", 
			@main_pane.join( @sub_pane.next_page ) )
	end

	# Displays the previous page for the Main pane, if it exists.
	def previous
		replace( '2.0', "#{@lines - 1}.end", 
			@main_pane.previous_page.join( @sub_pane.current_page ) )
	end

	# Displays the previous page for the Sub pane, if it exists.
	def previous_sub
		replace( '2.0', "#{@lines - 1}.end", 
			@main_pane.join( @sub_pane.previous_page ) )
	end

	private

	# Determine how many lines are 
	def lines_of_text( text )
		text.split( "\n" ).size	
	end

end # TextManager