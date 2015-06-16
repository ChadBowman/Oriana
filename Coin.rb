class Coin
	attr_accessor :value
	def initialize( value = 0 )
		self.value = value
	end
	def value=( value )
		case value
		when Fixnum
			@value = value										# No formatting needed
		when Float
			value < 0 ? value -= 0.005001 : value += 0.005001	# Round last penny
			self.value = value.to_s[/-?\d*\.\d{0,2}/] 			# Process as string with remainder chopped
		when String
			if( value =~ /^(\$?|?)0*\.?0*$/ )					# All zeros or ''
				@value = 0
			elsif( value =~ /^-?\d*$/ )						# With cent sign
				@value = Integer( value.sub( /0*/, '' ))		# Remove cent symbol, leading zeros
			elsif( value =~ /^-?\$?\d*\.\d{0,2}$/ )				# With decimal point
				value += '00' if value =~ /\.$/					# Add missing zeros
				value += '0'  if value =~ /\.\d$/
				value.sub!( '-', '-$' ) if value =~ /^-\d/		# Add $ if negative and no $ exists
				value.gsub!( /\$0*|^0*/, '' ).sub!( /\./, '' )	# Remove leading 0s and '$', '.'  
				@value = Integer( value )						# Remove symbols and leading zeros
			elsif( value =~ /^-?\$?\d*$/ )						# Without decimal
				value.sub!( '-', '-$' ) if value =~ /^-\d/		# Add $ if negative and no $ exists
				value.gsub!( /\$0*|^0*/, '' )					# Remove symbols and leading zeros
				@value = Integer( value + '00' )				# Convert from dollar to cents
			else
				raise ArgumentError.new( "Coin input format invalid! [#{value}]" )
			end
		when Coin
			@value = value.value
		else
			raise TypeError.new( "Coin input type invalid! [#{value.class}]" )
		end
	end
	# Opp Overrides
	def +( coin ) @value + Coin.new( coin ).value end
	def -( coin ) @value - Coin.new( coin ).value end
	def *( coin ) @value * Coin.new( coin ).value end
	def /( coin ) @value / Coin.new( coin ).value end
	def %( coin ) @value % Coin.new( coin ).value end
	def **( coin ) @value ** Coin.new( coin ).value end
	def <=>( coin ) @value <=> Coin.new( coin ).value end
	# Safe divide
	# Returns array with quotient and remainder
	def divide( coin )
		x = Coin.new( coin ).value
		return @value / x, @value % x
	end
	# Sets quotient to value, returns the remainder
	def divide!( coin )
		x = Coin.new( coin ).value
		@value, remainder = @value / x, @value % x
		return remainder
	end
	def to_s
		if( @value.to_s.sub( '-', '' ).length > 2 )
			x = @value.to_s.insert( -3, '.' )
			if( x =~ /-/ )
				x.sub!( '-', '-$' )
			else
				x.insert( 0, '$' )
			end
		else
			if( @value.to_s =~ /-/ )
				@value.to_s.sub('-', '-
			else 
				@value.to_s.insert( 0, '
			end
		end
	end
	def to_i() @value end
end
