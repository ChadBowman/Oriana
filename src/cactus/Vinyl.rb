 


require_relative '../ebay/Item'


class Vinyl < Item

	NEW = '1000'
	USED = '3000'

	attr_accessor :discogs_id, :format, :size, :duration, :genre, :styles,
		:album, :artists, :year, :country, :attributes, :genres, :image


	def initialize
		@attributes = Array.new
	end

	def parse_attributes( formats )
		
		ats = Hash.new

		formats.each do |format|
		
			unless format[:descriptions].nil?
				format[:descriptions].each do |desc|
					ats[ desc ] = true
				end
			end

			unless format[:name].nil?
				format[:name].split(', ').each do |desc|
					ats[ desc ] = true
				end
			end

			unless format[:text].nil?
				format[:text].split(', ').each do |desc|
					ats[ desc ] = true
				end
			end

		end # formats.each

		@size = "12\""

		ats.each_key do |key|

			case key
			when 'LP', 'EP', 'Single', 'Box Set', 'Double LP', 'Tripple LP'
				@duration = key unless @duration == 'Box Set'
				ats.delete key

			when 'Vinyl', 'CD'

				puts "Format nil? #{@format.nil?}"
				if @format.nil?
					@format = key
				else
					@format = "#{@format} #{key}"
					puts "Added #{@format}"
				end

				ats.delete key
				puts "Leaving switch"

			when "7\"", "10\""
				@size = key
				ats.delete key

			when 'Album'
				ats.delete key

			end

		end # each_key

		ats.each_key{ |key| @attributes << key }

		@attributes

	end # parse_attributes

	def special_attributes

		ret = Hash.new
		ret[:colored] = color if color
		ret[:speed] = speed if speed
		ret[:heavy] = '180 - 220 gram' if check(/gram/i)
		ret[:picture] = 'Picture Disc' if check(/picture/i)
		ret[:reissue] = 'Reissue' if check(/reissue/i)
		ret[:shaped] = 'Shaped' if check(/shaped/i)
		ret[:compilation] = 'Compilation' if check(/compilation/i)
		ret[:limited] = 'Limited Edition' if check(/limited/i)
		ret[:remastered] = 'Remastered' if check(/remastered/i)
		ret[:special] = 'Special Edition' if check(/special/i)
		ret[:etched] = 'Etched' if check(/etched/i)
		ret[:numbered] = 'Numbered' if check(/numbered/i)
		ret[:quadraphonic] = 'Quadraphonic' if check(/quadraphonic/i)

		#live
		#1st edition
		#import

		ret
		
	end


	def make_title

		puts "Making title"
		artist = @artists.first.upcase

		front = "#{artist} #{@album} "

		if @format == 'Vinyl'
			back = "#{@size} Vinyl #{@duration}"
		elsif @duration.nil?
			back = "#{@format}"
		else
			back = "#{@format} #{@duration}"
		end

		
		title = front + back


		@attributes.each do |at|

			front = front + "#{at} "

			title = front + back if (front + back).length < 81
				
		end
		
		puts "Title Made"

		title 
	end # make_title

	private
	def check( regexp )

		@attributes.each do |at|
			return true if at =~ regexp
		end

		false
	end

	def speed
		@attributes.each do |at|
			return at if at =~ /rpm/i
		end

		false
	end

	def color
		@attributes.each do |at|
			if at =~ /(red|blue|green|purple|yellow|orange|white|black|clear|transparent|translucent|pink)(.*vinyl)?/i
				return at
			end
		end

		false
	end

end # Vinyl

