require 'tk'

class Console

	def initialize( title = 'Console' )
		
		@root = Tk::Root.new{ title( title ) }

		@output = Tk::Text.new( @root ) do 
			height( 25 )
			width( 100 )
			pack
		end

		@input = Tk::Entry.new( @root ) do 
			bind( '<return>', proc{ submit_input } )
			takefocus( 1 )
			pack( side: 'bottom', fill: 'x' ) 
		end

		@in_string = ''

		@root.mainloop
	end

	def submit_input
		@in_string = @input.get
		@input.delete

		@output.insert('end', @in_string )
	end

end

Console.new