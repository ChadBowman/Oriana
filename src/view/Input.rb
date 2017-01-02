# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2015 Orthus Technology
# License::   Distributes under the same terms as Ruby

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
	# +remove+:: Regexp of stuff to remove from argument
	def get_flags( remove = nil )

		# escape dashes for split
		@value.gsub!(/\\\-/, "<dash>")

		# Remove command, split by spaces
		if remove.nil?
			vars = @value.split '-'
		else
			vars = @value.gsub( remove, '' ).split '-'
		end

		# Hash to return
		flags = Hash.new
		# for each pair of arguments, place in Hash
		# 	flags[ flag ] = argument
		vars.each do |str|
		
			# Extract key and value
			key = str[/^\S+/]
			value = str.sub(/^\S+ /, '' ).gsub("<dash>", '-')

			# parse true/false values
			value = true if value.downcase == 'yes' or value.downcase == 'true'
			value = false if value.downcase == 'no' or value.downcase == 'false'

			value.chop! if value[-1] =~ /\s/
			value = nil if value == ''

			flags[ key.to_sym ] = value unless key.nil?
			
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
			if element.include? 'yes' or element.include? 'true'
				element = true
			elsif element.include? 'no' or element.include? 'false'
				element = false
			end
			# Return to map
			element
		end
		
		# Return element if only 1 exists, else the array
		vars = vars.length == 1 ? vars.first : vars

	end # get_vars

end # Input