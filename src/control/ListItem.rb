

require_relative 'Control'
require_relative '../view/Image'
require_relative '../cactus/Vinyl'
require_relative '../utility/Constants'
require_relative '../ebay/ReturnPolicy'
require_relative '../ebay/ShippingOption'
require_relative '../utility/XML'

class ListItem < Control

	def initialize
		super( /list / )	
	end

	def action( input )

		if input.value =~ /^list$/
			@vinyl = nil
		end
		
		puts "Vinyl nil? #{@vinyl.nil?}"
		
		# vinyl nil only when new listing is being made
		if @vinyl.nil?
			clear_binds

			@vinyl = Vinyl.new
			handle_flags input
			@vinyl.upc = input.value[/ \d+ ?$/].gsub(/\s/, '')

			puts "UPC: #{@vinyl.upc}"

			@out.thinking
			results = @profile.discogs.search @vinyl.upc
			@out.done_thinking

		
			# More than one match found.
			if results.size == 1

				puts "Only 1 result found, molding.."
				mold_vinyl results.first[:id]

			elsif results.size > 1

				puts "Comparing countries"
				compare_countries results

			else
				@out.prompt "No release found!"

			end

		else # vinyl.nil?

			handle_flags input
			puts 'Posting to display'
			@out.post_sub( sub_pane )
			@out.post( display, @vinyl.image )

		end # vinyl.nil?

		# Reset entry
		@entry.insert( 0, "#{input.value} " )
		puts "Done in action"

	end # action

	def handle_flags( input )
		
		puts "Checking flags"
		# Remove 'list ' and the UPC
		flags = input.get_flags( /(list | \d{5,} ?)/ )
		puts "Flags checked: #{flags.size}"

		flags.each do |key, value|
			puts "Handling flag #{key}"

			case key
			when :p 
				begin
					@vinyl.price = Coin.new( value ).to_f
					@vinyl.best_offer_decline = Coin.new( @vinyl.price * 0.75 ).to_f
				rescue Exception => e
					@out.prompt "Invalid price format!"
				end

			when :q 
				if value =~ /^\d$/
					value = Integer( value )

					if value > 0 
						@vinyl.quantity = value
					else
						@out.prompt 'Quantity must be greater than 1!'
					end
				else
					@out.prompt 'Quantity format wrong!'
				end

			when :c
				if value =~ /^(new|used)$/i
					if value =~ /new/i 
						@vinyl.condition_id = Vinyl::NEW
					elsif value =~ /used/i
						@vinyl.condition_id = Vinyl::USED
					end
				else
					@out.prompt 'Condition can either be new or used!'
				end

			when :t
				if value.length < 81
					@vinyl.title = value
				else
					@out.prompt "Title can only be 80 characters long!"
				end

			when :d
				@detailed_desc = value
			end

		end

		puts "Leaving flags"
	end

	def compare_countries( array )
		
		# Stack of unique countries
		stack = Hash.new
		# Gather unique counties 
		array.each do |record|
			stack[ record[:country] ] = true
		end

		puts "Number of different countries: #{stack.size}"

		# If more than 1 unique country exits, have user choose.
		if stack.size > 1
			t = "#{array.first[:title].sub(/\(\d\)/, '')}\n\n"
			t << "    Which country was this release made in?\n"

			clear_binds
			# For each unique country, add bind and display
			i = 1
			stack.each_key do |country|

				t << "      [F#{i}] #{country}\n"
				
				bind i do
					# new array with less elements
					new_arr = Array.new
					array.each do |record|
						new_arr << record if record[:country] == country
					end
					
					if new_arr.size == 1
						puts "Molding vinyl"
						mold_vinyl new_arr.first[:id]

					else
						puts "Selection not down to 1! #{new_arr.size}"
						compare_features new_arr
					end

				end # do

				i += 1

			end # stack.each

disp = <<-EOF
#{banner 'List Vinyl'}


    #{t.chop}
EOF
			@out.post disp
		else

			puts "No different countries, comparing features"
			compare_features array

		end # if stack > 1

	end # compare_countries

	def compare_features( releases )
		
		all = Array.new

		@out.thinking
		releases.each do |release|
			details = @profile.discogs.get_release release[:id]
			text = ''
			Vinyl.new.parse_attributes( details[:formats] ).each do |element|
				text << "#{element}, "
			end
			text.chop!
			text.chop!
			all << text
		end
		@out.done_thinking

		t = "#{releases.first[:title].sub(/\(\d\)/, '')}\n\n"
		t << "    Which features match this release?\n"

		clear_binds
		all.each_with_index do |info, i|
			t << "      [F#{i+1}] #{info}\n"

			bind(i+1) do
				puts "Molding vinyl"
				mold_vinyl releases[i][:id]
			end

		end

disp = <<-EOF
#{banner 'List Vinyl'}


    #{t.chop}
EOF
		@out.post disp

	end # compare_features

	def mold_vinyl( release_id )

		@out.thinking

		# Retrieve release from Discogs
		release = @profile.discogs.get_release release_id
	
		# Simplify artists
		artists = Array.new
		release[:artists].each do |hash|
			artists << hash[:name].sub(/ *\(\d\) */, '')
		end
		@vinyl.artists = artists

		# Get specifics from release
		@vinyl.category = Cactus::EBAY_VINYL_CATEGORY
		@vinyl.discogs_id = release_id

		if release.title == @vinyl.artists.first
			@vinyl.album = "S/T"
		else
			@vinyl.album = release.title
		end

		@vinyl.year = release[:year]
		@vinyl.country = release[:country]
		@vinyl.genre = release[:genres].first
		@vinyl.styles = release[:styles]
		@vinyl.parse_attributes release[:formats]

		# Thumbnail for user
		@vinyl.image = Image.new release[:thumb]
		@vinyl.title = @vinyl.make_title if @vinyl.title.nil?
		@vinyl.quantity = 1 if @vinyl.quantity.nil?
		
		# Larger images for listing
		images = Array.new
		imgs = ''
		if false
		
			release[:images].each_with_index do |img, i|
				#images << "Vinyl #{i+1}"
				images << img[:uri]
				puts "Added #{img[:uri]}"
			end
			
			@out.prompt "Uploading images..."
			responses = @profile.courier.upload_pictures images
			@out.prompt "Upload complete..."

			
			responses.each_with_index do |xml, i|
				imgs << "<PictureURL>#{xml['FullURL']}</PictureURL>" if i < 12
			end

		else
			imgs = "<PictureURL>#{release[:images].first[:uri]}</PictureURL>"
		end


		@vinyl.picture_urls = imgs

		# Listing specifics
		@vinyl.list_duration = Ebay::GOOD_TIL_CANCELED
		@vinyl.dispatch_time = 1
		@vinyl.condition_id = Vinyl::NEW if @vinyl.condition_id.nil?
		@vinyl.list_type = Ebay::FIXED
		@vinyl.best_offer = true
		@vinyl.description = description( @detailed_desc )

		puts 'Binding list'
		bind(1){ list }

		puts 'Posting to display'
		
		@out.post_sub( sub_pane )
		@out.post( display, @vinyl.image )

	end # mold_vinyl

	def list

		if @profile.ready?
			vars = @vinyl.get_var_hash.merge @profile.ebay

			if @vinyl.price.nil?
				@out.prompt "A price is required!"
			else

				specifics = Hash.new
				specifics[:size] = @vinyl.size
				specifics[:duration] = @vinyl.duration
				specifics[:genre] = @vinyl.genre
				specifics[:styles] = @vinyl.styles
				specifics[:year] = @vinyl.year
				specifics.merge! @vinyl.special_attributes
				vars[:specifics] = specifics
				vars[:store_category1] = '4646348015'

				# Return Policy/ Shipping
				vars[:return_policy] = ReturnPolicy.new.to_XML

				s = ShippingOption.new
				s.service = 'USPSMedia'
				s.priority = 1
				s.cost = '4'
				s.weight_major = '2'
				s.weight_minor = '0'
				vars[:shipping_options] = s.to_XML

				
				@out.thinking
				result = @profile.courier.add_item vars
				@out.done_thinking

				@out.center result['Ack']
				puts result
				@vinyl = nil
				@entry.set 'list '
				#TODO save vinyl somewhere? SQL maybe?
		

			end

		else
			@out.prompt 'Your profile is incomplete!'

		end
		
			
	end # list



	def display

		condition = 'New' if @vinyl.condition_id == Vinyl::NEW
		condition = 'Used' if @vinyl.condition_id == Vinyl::USED
		country = "#{@vinyl.country}, #{@vinyl.year}"

		unless @vinyl.special_attributes.empty?
			ats = "Attributes:\n"

			@vinyl.special_attributes.each_value do |value|
				ats << "      #{value}\n"
			end
		end

<<-EOF
#{banner 'List Vinyl'}
	#{@vinyl.title}		


	#{"%-40sPrice:     %s" % [@vinyl.artists.first, @vinyl.price]}
	#{"%-40sQuantity:  %s" % [@vinyl.album, @vinyl.quantity]}
	#{"%-40sCondition: %s" % [country, condition]}
	#{"%-40s" % @vinyl.genre}

	#{ats}
	[F1] List
	[F12] Cancel
EOF
	end

	def sub_pane
<<-EOF




	--- Options --- 
  -p Price
  -q Quantity
  -c Condition
  -t Title
  -d Description
EOF
	end

	def description( desc = nil, vinyl_code = nil, jacket_code = nil, 
			vinyl_desc = nil, jacket_desc = nil )

		# Defaults
		if @vinyl.condition_id == Vinyl::NEW
			vinyl_code = 'M'
			jacket_code = 'M'
			vinyl_desc = 'Brand new!'
			jacket_desc = "Brand new!"
		end

		# Append artists
		if @vinyl.artists.size == 1
			artist = @vinyl.artists.first

		elsif @vinyl.artists.size > 1
			artist = String.new

			@vinyl.artists.each do |art|
				artist << "#{art}, "
			end
			artist.chop!
			artist.chop!
		end


		begin
			
			file = File.read 'cactus/description.html'


			file.sub!("{artist}", artist)
			file.sub!("{album}", @vinyl.album)
			file.sub!("{jacket_code}", jacket_code)
			file.sub!("{vinyl_code}", vinyl_code)
			
			file.sub!("{duration}", @vinyl.duration) unless @vinyl.duration.nil?


			if desc.nil?
				file.sub!("{itm}", '')
				file.sub!("{desc}", '')
			else
				file.sub!("{itm}", 'Item Description:')
				file.sub!("{desc}", desc)
			end

			if jacket_desc.nil?
				file.sub!("{jacket_desc}", '')
			else
				file.sub!("{jacket_desc}", jacket_desc)
			end

			if vinyl_desc.nil?
				file.sub!("{vinyl_desc}", '')
			else
				file.sub!("{vinyl_desc}", vinyl_desc)
			end


			"<![CDATA[#{file}]]>"

		rescue Exception => e
			@out.prompt "Problem making description!"
			puts e.to_s unless e.nil?
			puts e.backtrace unless e.nil?
		end

	end # description

end # ListItem