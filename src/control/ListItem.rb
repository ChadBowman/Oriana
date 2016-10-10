

require 'green_shoes'
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

		flag = true
		
		puts "Vinyl nil? #{@vinyl.nil?}"
		
		# vinyl nil only when new listing is being made
		if @vinyl.nil?
			clear_binds
			add_images_manually = false

			@vinyl = Vinyl.new
			@vinyl.upc = 'NA'
			@image_urls = Array.new
			@shipping = ShippingOption.new
			@shipping.service = ShippingOption::Services::MEDIA
			@shipping.priority = 1
			@shipping.weight_major = '2' 
			@shipping.weight_minor = '0'

			@vinyl_con =  Vinyl::DEFAULT_VINYL_CONDITION
			@vinyl_des =  Vinyl::DEFAULT_VINYL_DESCRIPTION
			@jacket_con = Vinyl::DEFAULT_JACKET_CONDITION
			@jacket_des = Vinyl::DEFAULT_JACKET_DESCRIPTION

			@vinyl.list_type = Ebay::FIXED
			@vinyl.list_duration = Ebay::GOOD_TIL_CANCELED

			handle_flags input

			search_term = input.value[/ \d+ ?$/]

			if search_term.nil?
				search_term = input.value[/\".*\"$/].gsub(/\"/, '')
			else
				search_term = search_term.gsub(/\s/, '')
				@vinyl.upc = search_term
			end

			@out.thinking
			results = @profile.discogs.search search_term
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
				@vinyl = nil

			end

		else # vinyl.nil?

			flag = handle_flags input

			@out.post_sub( sub_pane )
			@out.post( display, @vinyl.image )

			unless @vinyl.image.nil?
				if @vinyl.image.dimensions.first < 500
					@out.prompt "Image must be at least 500px wide!"
				end
			end

		end # vinyl.nil?

		# Reset entry
		@entry.insert( 0, "list #{@vinyl.upc} " ) if flag and !@vinyl.nil?

	end # action

	def handle_flags( input )
		
		# Remove 'list ' and the UPC
		flags = input.get_flags( /(list | \d{5,} ?$|\".*\"$)/ )
		puts flags.to_s

		flags.each do |key, value|
			
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
				if value =~ /^(new|used)$/i or value.nil?
					if value.nil?

						case @vinyl.condition_id
						when Vinyl::NEW
							@vinyl.condition_id = Vinyl::USED
						when Vinyl::USED
							@vinyl.condition_id = Vinyl::NEW
						end

					elsif value =~ /new/i 
						@vinyl.condition_id = Vinyl::NEW
					elsif value =~ /used/i
						@vinyl.condition_id = Vinyl::USED
					end
				else
					@out.prompt 'Condition can either be new or used!'
				end

			when :t

				if value == 't'
					@entry.insert(0, "list -t #{@vinyl.title.gsub(/\-/, "\\-")}")
					return false

				elsif value.length < 81
					@vinyl.title = value
					@vinyl.title.gsub!(/\\-/, '-')

				else
					@vinyl.title = value.gsub!(/\\-/, '-')

					if value =~ /##/
						@vinyl.title = @vinyl.make_title_end( @vinyl.title )
					end

					if @vinyl.title.length > 80
						@out.prompt "Title can only be 80 characters long!"
					end

				end

			when :w
				if value =~ /^\d$/
					value = Integer( value )

					if value > 0 
						@shipping.weight_major = value.to_s
					else
						@out.prompt 'Weight must be greater than 0!'
					end
				else
					@out.prompt 'Weight format wrong!'
				end

			when :d
				@detailed_desc = value

			when :v
				# Separate code from description
				@vinyl_con = value[/^\S+\s/]
				@vinyl_con.sub!(/\s$/, '')
				@vinyl_des = value[/\s.*$/]
				@vinyl_des.sub!(/^\s/, '')

			when :j
				# Separate code from description
				@jacket_con = value[/^\S+\s/]
				@jacket_con.sub!(/ \s$/, '')
				@jacket_des = value[/\s.*$/]
				@jacket_des.sub!(/^\s/, '')

			when :i
				if value == 'i'
					result = ask_open_file
					@image_urls = result if add_images_manually == false 
					@image_urls << result if add_images_manually == true
					
					add_images_manually = true
				else
					@image_urls = value.split(/, ?/)
				end

			when :l
				if value =~ /auction/i
					@vinyl.list_type = Ebay::AUCTION
					@vinyl.list_duration = Ebay::DAYS_7

					if '10' =~ /\d*$/
						@vinyl.list_duration = Ebay::DAYS_10
					end

				elsif value =~ /fixed/i

					@vinyl.list_type = Ebay::FIXED
				
				end

			end # switch

		end # flags.each

	end # handle_flags

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
			
			if i < 12
				bind(i+1) do
					puts "Molding vinyl"
					mold_vinyl releases[i][:id]
				end
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
		@out.done_thinking
	
		# Simplify artists
		artists = Array.new
		release[:artists].each do |hash|
			artists << hash[:name].sub(/ *\(\d\) */, '')
		end
		@vinyl.artists = artists

		# Get specifics from release
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
		unless release[:images].nil?
			
			release[:images].each_with_index do |img, i|
				@image_urls << img[:uri] if i < 12
			end
		end
	
		@vinyl.picture_urls = "<PictureURL>#{@image_urls.first}</PictureURL>"

		# Listing specifics
		@vinyl.dispatch_time = 1
		@vinyl.condition_id = Vinyl::NEW if @vinyl.condition_id.nil?
		@vinyl.best_offer = true
		#@vinyl.description = description( @detailed_desc, @vinyl_con, @jacket_con, @vinyl_des, @jacket_con )

		bind(1){ list }
		bind(2){ upload_images }
		bind(12){ @vinyl = nil }
		
		@out.post_sub( sub_pane )
		@out.post( display, @vinyl.image )

	end # mold_vinyl

	def upload_images
		
		Thread.new{
			@out.center "Uploading images..."
			responses = @profile.courier.upload_pictures @image_urls
			
			@image_urls = Array.new
			responses.each_with_index do |xml, i|
				@image_urls << "<PictureURL>#{xml['FullURL']}</PictureURL>"
			end

			@vinyl.picture_urls = @image_urls
			@out.center "Upload complete!"
		}
		
	end

	def list

		puts "Listing #{@vinyl.title}..."

		@vinyl.description = description( @detailed_desc, @vinyl_con, @jacket_con, @vinyl_des, @jacket_des )

		if @profile.ready?
			vars = @vinyl.get_var_hash.merge @profile.ebay

			if @vinyl.price.nil?
				@out.prompt "A price is required!"
			else

				# Listing category and 
				if @vinyl.format =~ /Vinyl/
					vars[:category] = Cactus::EBAY_VINYL_CATEGORY
					vars[:store_category1] = Cactus::VINYL

				elsif @vinyl.format == Vinyl::CD
					vars[:category] = Cactus::EBAY_CD_CATEGORY
					vars[:store_category1] = Cactus::CDS
				end

				specifics = Hash.new
				specifics[:size] = @vinyl.size
				specifics[:duration] = @vinyl.duration
				specifics[:genre] = @vinyl.genre
				specifics[:styles] = @vinyl.styles
				specifics[:year] = @vinyl.year

				if @vinyl_con.nil?
					case @vinyl.condition_id

					when Vinyl::NEW
						specifics[:record_grading] = "Mint (M)"

					when Vinyl::USED
						specifics[:record_grading] = "Very Good Plus (VG+)"
					end
				else
					specifics[:record_grading] = @vinyl_con
				end

				if @vinyl_des.nil?
					case @vinyl.condition_id
					when Vinyl::NEW
						specifics[:sleeve_grading] = "Mint (M)"

					when Vinyl::USED
						specifics[:sleeve_grading] = "Very Good (VG)"

					end
				else
					specifics[:sleeve_grading] = @jacket_con
				end

				specifics.merge! @vinyl.special_attributes
				vars[:specifics] = specifics

				case @vinyl.genre
				when 'Rock'
					vars[:store_category2] = Cactus::ROCK
				when 'Jazz'
					vars[:store_category2] = Cactus::JAZZ
				when 'Country'
					vars[:store_category2] = Cactus::COUNTRY
				when 'Hip Hop'
					vars[:store_category2] = Cactus::HIPHOP
				when 'Electronic'
					vars[:store_category2] = Cactus::ELECTRONIC
				else
					puts "Genere #{@vinyl.genre} not categorized in ebay store!"
				end

				# Return Policy/ Shipping
				vars[:return_policy] = ReturnPolicy.new.to_XML


				priority = ShippingOption.new
				priority.priority = 2
				priority.service = ShippingOption::Services::PRIORITY

				international = ShippingOption.new
				international.priority = 3
				international.region = ShippingOption::INTERNATIONAL
				international.service = ShippingOption::Services::FIRST_CLASS_INT

				vars[:shipping_options] = @shipping.to_XML(priority, international)
				
				@out.thinking
				result = @profile.courier.add_item vars
				@out.done_thinking

				@out.center result['Ack']

				puts result if result['Ack'] != "Success"

				@vinyl = nil
				@image_urls = nil
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

		ats = Array.new
		unless @vinyl.special_attributes.empty?
			ats << "Attributes:"
			@vinyl.special_attributes.each_value do |value|
					ats << "      #{value}"
			end
		end

		@vinyl.artists = ['unkown'] if @vinyl.artists.nil?

		col = 34
		lines = Array.new
		lines << "%-#{col}s Price:       %s" % [@vinyl.artists.first, @vinyl.price]
		lines << "%-#{col}s Quantity:    %s" % [@vinyl.album, @vinyl.quantity]
		lines << "%-#{col}s %-28s Weight: %s" % [country, '', @shipping.weight_major + "lbs"]
		lines << "%-#{col}s Condition:   %s" % [@vinyl.genre, condition]
		lines << "%-#{col}s Description: %s" % ["Format: #{@vinyl.format}", @detailed_desc]
		lines << "%-#{col}s Vinyl:  %s" % [ats[0], "#{@vinyl_con} #{@vinyl_des}"]
		lines << "%-#{col}s Jacket: %s" % [ats[1], "#{@jacket_con} #{@jacket_des}"]
		lines << "%-#{col}s Listing: %s" % [ats[2], "#{@vinyl.list_type}, #{@vinyl.list_duration}"]
		tab = '    '

		text = String.new
		lines.each do |l|
			text << "#{tab}#{l}\n"
		end

<<-EOF
#{banner 'List Vinyl'}
	#{@vinyl.title}		


#{text}
EOF
	end

	def sub_pane
<<-EOF
  [F1] List
  [F2] Upload #{@image_urls.size} Images
  [F12] Cancel
EOF
	end

	def description( desc = nil, vinyl_code = nil, jacket_code = nil, 
			vinyl_desc = nil, jacket_desc = nil )

		# Defaults
		if @vinyl.condition_id == Vinyl::USED and vinyl_code == Vinyl::DEFAULT_VINYL_CONDITION
			vinyl_code = 'NM'
			jacket_code = 'VG'
			vinyl_desc = 'Looks and plays great!'
			jacket_desc = 'Great considering its age!'

			if desc.nil?
				desc = "Photos in listing may not be of actual product."
			else
				desc += "\n Photos in listing may not be of actual product."
			end
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
			file.gsub!("{format}", @vinyl.format)

			if @vinyl.format == Vinyl::CD
				file.sub!("{container}", "Case")
			else
				file.sub!("{container}", "Jacket")
			end

			if @vinyl.duration.nil?
				if @vinyl.format == Vinyl::VINYL
					file.sub!("{duration}", 'Record')
				else
					file.sub!("{duration}", '')
				end
			else
				file.sub!("{duration}", @vinyl.duration)
			end

			if desc.nil?
				file.sub!("{itm}", '')
				file.sub!("{desc}", '')
			else
				file.sub!("{itm}", 'Item Description:')
				file.sub!("{desc}", desc + '<br><br>')
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

			file.gsub!(/ & /, '&amp;')
			"<![CDATA[#{file}]]>"

		rescue Exception => e
			@out.prompt "Problem making description!"
			puts e.to_s unless e.nil?
			puts e.backtrace unless e.nil?
		end

	end # description

end # ListItem