# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2015 Orthus Technology
# License::   Distributes under the same terms as Ruby

# A class to represent currency to the penny
class Coin

	# +value+:: integer representation of currency. Equivalent to a penny.
	attr_accessor :value

	# +value+:: String, Integer, Float, or Coin input to initialize value.
	def initialize( value = 0 )
		self.value = value
	end

	# +value+:: Accepts and normalizes any valid input
	def value=( value )

		case value
		when Fixnum
			@value = value										# No formatting needed

		when Float
			value < 0 ? value -= 0.005001 : value += 0.005001	# Round last penny
			self.value = value.to_s[/-?\d*\.\d{0,2}/] 			# Process as string with remainder chopped

		when String
			if value =~ /^(\$?|¢?)0*\.?0*$/						# All zeros or ''
				@value = 0

			elsif value =~ /^-?¢\d*$/							# With cent sign
				@value = Integer( value.sub( /0*¢/, '' ))		# Remove cent symbol, leading zeros

			elsif value =~ /^-?\$?\d*\.\d{0,2}$/				# With decimal point
				value += '00' if value =~ /\.$/					# Add missing zeros
				value += '0'  if value =~ /\.\d$/
				value.sub!( '-', '-$' ) if value =~ /^-\d/		# Add $ if negative and no $ exists
				value.gsub!( /\$0*|^0*/, '' ).sub!( /\./, '' )	# Remove leading 0s and '$', '.'  
				@value = Integer( value )						# Remove symbols and leading zeros

			elsif value =~ /^-?\$?\d*$/							# Without decimal
				value.sub!( '-', '-$' ) if value =~ /^-\d/		# Add $ if negative and no $ exists
				value.gsub!( /\$0*|^0*/, '' )					# Remove symbols and leading zeros
				@value = Integer( value + '00' )				# Convert from dollar to cents

			else
				raise ArgumentError, "Coin input format invalid! [#{value}]"
			end

		when Coin
			@value = value.value								# No formatting needed
		else
			raise TypeError, "Coin input type invalid! [#{value.class}]"
		end

	end # value=

	# Integer math only
	def *( coin ) @value * Coin.new( coin ).value end
	# Integer math only
	def /( coin ) @value / Coin.new( coin ).value end
	def +( coin ) @value + Coin.new( coin ).value end
	def -( coin ) @value - Coin.new( coin ).value end
	def %( coin ) @value % Coin.new( coin ).value end
	def **( coin ) @value ** Coin.new( coin ).value end
	def <=>( coin ) @value <=> Coin.new( coin ).value end

	def multiply_by( input )
	
		if input == 0
			return 0
		elsif input < 1.0 and input > -1.0
			divide_by( 1.0/input )
		else
			self * input
		end

	end

	# Conserving divide
	# Returns array with quotient and remainder
	def divide_by( input )
		

		raise ZeroDivisionError, 'You tried to divide by zero!' if input == 0

		c = Coin.new input

		case input
		when Fixnum, Coin
			value, remainder = @value / c.value, @value % c.value
		when Float

			if input > -1.0 and input < 1.0
				@value.to_f / input
			else
				return @value / 100.0 / input, ( @value / 100.0 ) % input
			end
		end

	end

	# Conserving divide
	# Sets quotient to value, returns the remainder
	def divide_by!( coin )
		x = Coin.new( coin ).value
		@value, remainder = @value / x, @value % x
		return remainder
	end

	def to_i() @value end

	def to_f
		@value.to_f / 100
	end

	def to_s

		if @value.to_s.sub( '-', '' ).length > 2	# If greater than a dollar

			x = @value.to_s.insert( -3, '.' )		# Insert decimal point

			if x =~ /-/								# If negative
				x.sub!( '-', '-$' )					# Add $
			else
				x.insert( 0, '$' )
			end
		else										# Less than a dollar
			if @value.to_s =~ /-/					# If negative
				@value.to_s.sub('-', '-¢')			# Add cent symbol
			else 
				@value.to_s.insert( 0, '¢')
			end
		end

	end # to_s	

end # Coin