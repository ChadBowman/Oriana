 


require_relative '../ebay/Item'


class Vinyl < Item

	NEW = '1000'
	USED = '3000'

	DEFAULT_VINYL_CONDITION = 'M'
	DEFAULT_JACKET_CONDITION = 'M'
	DEFAULT_VINYL_DESCRIPTION = 'Brand New!'
	DEFAULT_JACKET_DESCRIPTION = 'Brand New!'

	VINYL = 'Vinyl'
	CD = 'CD'

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

			when VINYL, CD

				if @format.nil?
					@format = key
				else
					@format = "#{@format} #{key}"
				end

				ats.delete key

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

	
		make_title_end("#{@artists.first.upcase} #{@album} ").gsub('  ', ' ')


	end # make_title

	def make_title_end( front )
		
		if @format.eql? VINYL
			back = "#{@size} Vinyl #{@duration}"
		elsif @duration.nil?
			back = "#{@format}"
		else
			back = "#{@format} #{@duration}"
		end

		
		title = front + back

		n = 1
		while title.length > 80
			title = front[0...front.length-n] + back
			n += 1
		end

		@attributes.each do |at|

			at = at.sub(/ Edition/i, '') if at.include? 'Edition'
			at = at.sub(/ ?gram/i, 'g')

			front = front + "#{at} "

			title = front + back if (front + back).length < 81
				
		end
		
		title 

	end

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
			if at =~ /((^| )red|blue|green|purple|yellow|orange|white|black|clear|transparent|translucent|pink|gold|silver)/i
				return at
			end
		end

		false
	end

end # Vinyl

