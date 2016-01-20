# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2015 Orthus Technology
# License::   Distributes under the same terms as Ruby

require_relative '../utility/Thread'

# Connects the view (Console) to the Model.
# Ideally, this class should always be extended, however for very quick and 
# simple uses, this can be built after creating the instance as follows.
# Here is an example of this being used as an instance:
=begin
	Control.new(/add /) do
		<<-EOF
		vars = input.get_vars 'add'
		total = 0
		vars.each{ |x| total += Integer(x) }
		@entry.set 'add '
		@out.post '%sThe Total is: %d' % ["\n", total]
		EOF
	end
=end
class Control 

	# Instance variables
	# +root+:: Tk::Root root frame 
	# +entry+:: Tk::Entry input for editing entry box.
	# +out+:: TextManager for all data output processing.
	# +model+:: Object housing all data representing current state of program.
	attr_writer :root, :entry, :out, :console, :profile
	# +prompt+:: Regexp which identifies command and when it should be used.
	attr_reader :prompt

	# Parameters:
	# +profile+:: Object state of system (to be implemented)
	# +prompt+:: Regexp checking when an input should trigger this command.
	# If false, this command will be ran on startup and not added to the control
	# stack.
	def initialize( prompt = false )

		@prompt = prompt
		
		# This string is only assigned when a quick command created via an 
		# instance of Command. More through 
		@code = yield if block_given?

	end

	protected
	
	# Parameter:
	# +input+:: Input special type of input string class.
	def action( input = nil )

		# evaluate @code added via the constructor
		eval(@code) unless @code.nil?

	end


	def clear_binds
		(1..12).each{ |n| unbind n }
	end

	# Binds particular key and ensures the extry field behaves as expected by not
	# printing the key pressed
	#
	# Parameter:
	# +key+:: Key to bind code to
	def bind( key )
		if key.is_a? Fixnum
			if key < 13 and key > 0
				@root.bind( "F#{key}" ){ yield }
			else
				raise ArgumentError, "Bind must be 1 to 12!"
			end
		end
	end
 

	# Properly unbinds key from root. Sets entry back to behave normally
	#
	# Parameter:
	# +key+:: Key to unbind
	def unbind( key )
		if key.is_a? Fixnum
			@root.bind( "F#{key}" ){ } 
		end
	end

	def run_command( command )
		@console.run_command command
	end

	def banner( text )
		"---------- #{text} -------------------------------------------"
	end

end # Control