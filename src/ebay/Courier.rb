# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2015 Orthus Technology
# License::   Distributes under the same terms as Ruby

require_relative 'Call'
require_relative '../utility/Constants'
require_relative '../view/Image'


# Sends and receives HTTPS callers to eBay with Call
class Courier

	def initialize( caller )
		@caller = caller
	end

	def token=( token )
		@caller.token = token		
	end

	def token
		@caller.token
	end

	#-----------------------

	# Look up ebay time.
	def ebay_time
		@caller.make_shop_call 'GeteBayTime'
	end

	def get_session_id
		
		call = 'GetSessionID'

		body = <<-END
		<RuName>#{Orthus::RUNAME}</RuName>
		<ErrorLanguage>en_US</ErrorLanguage>
		<WarningLevel>High</WarningLevel>
		END

		@caller.make_no_auth_trade_call( call, body )

	end

	def fetch_token( session_id )
		
		call = 'FetchToken'
		body = "<SessionID>#{session_id}</SessionID>"

		@caller.make_no_auth_trade_call( call, body )
	end

	# Look up top-level categories or child categories of any parent.
	def get_categories( parent = nil )
		
		call = 'GetCategories'

		if parent.nil?
			body = <<-END
				<CategorySiteID>0</CategorySiteID>
	  			<DetailLevel>ReturnAll</DetailLevel>
	  			<LevelLimit>1</LevelLimit>
			END
		else
			body = <<-END
				<CategoryParent>#{parent}</CategoryParent>
				<DetailLevel>ReturnAll</DetailLevel>
				<LevelLimit>2</LevelLimit>
			END
		end

		@caller.make_trade_call( call, body )

	end # get_categories

	def get_category_specifics( category )

		call = 'GetCategorySpecifics'

		body = <<-END
			<CategorySpecific>
				<CategoryID>#{category}</CategoryID>
			</CategorySpecific>
			<WarningLevel>High</WarningLevel>
			<MaxNames>30</MaxNames>
			<MaxValuesPerName>5</MaxValuesPerName>
			<Name>Colored Vinyl</Name>
		END

		@caller.make_trade_call( call, body )
		
	end

	def get_category_features( category )

		call = 'GetCategoryFeatures'

		body = <<-END
			<WarningLevel>High</WarningLevel>
			<CategoryID>#{category}</CategoryID>
			<DetailLevel>ReturnAll</DetailLevel>
		END

		@caller.make_trade_call( call, body )
	end

	def find_products( keywords, page = 1, domain = nil )

		#if keywords.is_a? Fixnum
			keywords = "<ProductID type='UPC'>#{keywords}</ProductID>"
		#else
			#keywords = "<QueryKeywords>#{keywords}</QueryKeywords>"
		#end

		if domain.is_a? NilClass
			domain = ''
		else
			domain = '\n<DomainName>#{domain}</DomainName>'
		end

		caller = 'FindProducts'
		body = <<-END
			<AvailableItemsOnly>false</AvailableItemsOnly>
			<HideDuplicateItems>true</HideDuplicateItems>
			<MaxEntries>20</MaxEntries>
			<PageNumber>#{page}</PageNumber>
			#{keywords}#{domain}
			END

		@caller.make_shop_call( caller, body )

	end # find_products



	def get_active( page = 1 )

		caller = 'GetMyeBaySelling'
		body = <<-END
			<ActiveList>
				<Include>true</Include>
				<IncludeNotes>true</IncludeNotes>
				<Pagination>
					<EntriesPerPage>20</EntriesPerPage>
					<PageNumber>#{page}</PageNumber>
				</Pagination>
				<Sort>TimeLeft</Sort>
			</ActiveList>
			<DetailLevel>ReturnSummary</DetailLevel>
			<WarningLevel>High</WarningLevel>		
			END

		@caller.make_trade_call caller, body
	end 

	def get_sold( page = 1 )
		
		caller = 'GetMyeBaySelling'
		body = <<-END
			<SoldList>
				<Include>true</Include>
				<IncludeNotes>true</IncludeNotes>
				<Pagination>
					<EntriesPerPage>20</EntriesPerPage>
					<PageNumber>#{page}</PageNumber>
				</Pagination>
				<Sort>TimeLeft</Sort>
			</SoldList>
			<DetailLevel>ReturnSummary</DetailLevel>
			<WarningLevel>High</WarningLevel>		
			END

		@caller.make_trade_call caller, body
	end

	def get_purchased( page = 1 )
		
		call = 'GetMyeBayBuying'
		body = <<-END
			<WonList>
				<Include>true</Include>
				<IncludeNotes>true</IncludeNotes>
				<Pagination>
					<EntriesPerPage>20</EntriesPerPage>
					<PageNumber>#{page}</PageNumber>
				</Pagination>
				<Sort>EndTimeDescending</Sort>
			</WonList>
			<DetailLevel>ReturnSummary</DetailLevel>
			<WarningLevel>High</WarningLevel>
			END

		@caller.make_trade_call call, body
	end

	def upload_pictures( photos )
		
		responses = Array.new

		photos.each do |path|
			path = Image.new( path ).path if path =~ /http/
			responses.push @caller.upload_picture( "name", path )
		end


		if responses.is_a? NilClass
			nil
		elsif responses.size == 1
			responses.first
		else
			responses
		end

	end # upload_pictures

	def add_item( vars )

		call ='AddItem'
		@caller.make_trade_call( call, list_body( vars ) )

	end

	def verify_add_item( vars )

		call = 'VerifyAddItem'
		@caller.make_trade_call( call, list_body( vars ) )
		
	end

	private
	
	def list_body( vars )

		#ListingType
		fixed = true
		fixed = false if vars[:list_type] == 'Chinese'

		# OPTIONAL 
		options = ''

		# UUID
		unless vars[:id].nil? 
			options << "<UUID>#{vars[:id]}</UUID>"
		end

		#SKU
		options << "<SKU>#{vars[:sku]}</SKU>" unless vars[:sku].nil?

		# Condition Description
		x = vars[:condition_description]
		unless x.nil? 
			options << "<ConditionDescription>#{x}</ConditionDescription>"
		end

		# Buyer Violations
		x = vars[:buyer_policy_violations]
		unless x.nil?
			policy = 	"<MaximumBuyerPolicyViolations>
		        			<Period>Days_180</Period>
						</MaximumBuyerPolicyViolations>"
		end

		x = vars[:buyer_unpaid_items]
		unless x.nil?
			strikes =	"<MaximumUnpaidItemStrikesInfo>
		        			<Count>#{x}</Count>
		        			<Period>Days_180</Period>
		      			</MaximumUnpaidItemStrikesInfo>"
		end

		# Store categories
		x, y = vars[:store_category1], vars[:store_category2]
		unless x.nil?

			y = "<StoreCategory2ID>#{y}</StoreCategory2ID>" unless y.nil?

			options <<	"<Storefront>
		    				<StoreCategoryID>#{x}</StoreCategoryID>
		     				#{y}
		    			</Storefront>"
		end

		x = vars[:specifics]
		unless x.nil?
			
			specs = Array.new
			unless x[:size].nil?
				specs << "<Name>Record Size</Name><Value>#{x[:size]}</Value>"
			end

			unless x[:duration].nil?
				specs << "<Name>Duration</Name><Value>#{x[:duration]}</Value>"
			end

			unless x[:genre].nil?
				specs << "<Name>Genre</Name><Value>#{x[:genre]}</Value>"
			end

			unless x[:styles].nil?
				styles = "<Name>Style</Name>"
				x[:styles].each do |style|
					styles << "<Value>#{style}</Value>"
				end

				specs << styles
			end

			unless x[:year].nil?
				specs << "<Name>Release Year</Name><Value>#{x[:year]}</Value>"
			end

			special = Array.new
			special << "<Value>180 - 220 gram</Value>" unless x[:heavy].nil?
			special << "<Value>Picture Disc</Value>" unless x[:picture].nil?
			special << "<Value>Reissue</Value>" unless x[:reissue].nil?
			special << "<Value>Shaped</Value>" unless x[:shaped].nil?
			special << "<Value>Compilation</Value>" unless x[:compilation].nil?
			special << "<Value>Limited Edition</Value>" unless x[:limited].nil?
			special << "<Value>Remastered</Value>" unless x[:remastered].nil?
			special << "<Value>Special Edition</Value>" unless x[:special].nil?
			special << "<Value>Etched</Value>" unless x[:etched].nil?
			special << "<Value>Numbered</Value>" unless x[:numbered].nil?
			special << "<Value>Quadraphonic</Value>" unless x[:quadraphonic].nil?
			special << "<Value>Colored Vinyl</Value>" unless x[:colored].nil?

			unless special.empty?
				x = "<Name>Special Attributes</Name>"
				special.each do |line|
					x << line
				end

				specs << x			
			end
			

			specifics = String.new
			specs.each do |line|
				specifics << "<NameValueList>#{line}</NameValueList>"
			end

			specifics = "<ItemSpecifics>#{specifics}</ItemSpecifics>"

		end
		
 
		if fixed # Only allowed with fixed prices

			#AutoPay
			x = vars[:immediate_payment]
			if x.is_a? TrueClass or x.is_a? FalseClass
				options << "<AutoPay>#{x}</AutoPay>"
			end

			# Best Offer
			x = vars[:best_offer]
			if x.is_a? TrueClass or x.is_a? FalseClass
				options << "<BestOfferDetails>
								<BestOfferEnabled>#{x}</BestOfferEnabled>
							</BestOfferDetails>"

				# Best offer details
				x, y = vars[:best_offer_decline], vars[:best_offer_accept]
				unless x.nil?
					#decline = "<MinimumBestOfferPrice currencyID='USD'>#{x}</MinimumBestOfferPrice>"
				end

				unless y.nil?
					#accept = "<BestOfferAutoAcceptPrice currencyID='USD'>#{y}</BestOfferAutoAcceptPrice>"
				end


			end # best offer

		# Auction-style listing
		else

			# TODO check minimum percentage above start price
			# 	caller GetEbayDetails
			# 		DetailName = ListingStartPriceDetails
			# 		['ListingStartPriceDetails.MinBuyItNowPricePercent']
			x = vars[:buy_it_now_price]
			unless x.nil?
				options << "<BuyItNowPrice currencyID='USD'>
							#{x}</BuyItNowPrice>"
			end

		end

		unless vars[:upc].nil?
			options << "<ProductListingDetails>
							<UPC>#{vars[:upc]}</UPC>
						</ProductListingDetails>"
		end

		vars[:title] = vars[:title].gsub('&', '&amp;')

		<<-END
		<Item>
			<ListingType>#{vars[:list_type]}</ListingType>
			<ConditionID>#{vars[:condition_id]}</ConditionID>
		    <Country>US</Country>
		    <Currency>USD</Currency>
		    <Description>#{vars[:description]}</Description>
		    <DispatchTimeMax>#{vars[:dispatch_time]}</DispatchTimeMax>
		    <BuyerRequirementDetails>
				<ShipToRegistrationCountry>true</ShipToRegistrationCountry>
				#{policy}
				#{strikes}
	    	</BuyerRequirementDetails>
		    <ListingDuration>#{vars[:duration]}</ListingDuration>
		    <PaymentMethods>PayPal</PaymentMethods>
		    <PayPalEmailAddress>#{vars[:paypal_email]}</PayPalEmailAddress>
		    <PictureDetails>
		    	<GalleryType>Gallery</GalleryType>
		    	<PhotoDisplay>PicturePack</PhotoDisplay>
		      	#{vars[:picture_urls]}
		    </PictureDetails>
		    <PostalCode>#{vars[:zip]}</PostalCode>
		    <PrimaryCategory>
		    	<CategoryID>#{vars[:category]}</CategoryID>
		    </PrimaryCategory>
		    <Quantity>#{vars[:quantity]}</Quantity>
		    #{vars[:return_policy]}
			#{options}
	    	<Site>US</Site>
	    	<StartPrice currencyID='USD'>#{vars[:price]}</StartPrice>
	    	<Title>#{vars[:title]}</Title>
	    	#{vars[:shipping_options]}
	    	#{specifics}
	    </Item>
		<ErrorHandling>FailOnError</ErrorHandling>
		<ErrorLanguage>en_US</ErrorLanguage>
		<WarningLevel>High</WarningLevel>
		END

	end # list_body

end # Courier

#puts Courier.new( Call.new( Orthus::TOKEN, Orthus::PRODUCTION_APP_ID, Orthus::PRODUCTION_CERT_ID ) ).get_category_specifics( Cactus::EBAY_VINYL_CATEGORY )