# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2015 Orthus Technology
# License::   Distributes under the same terms as Ruby

require_relative 'Call'

# Sends and receives HTTPS callers to eBay with Call
class Courier

	def initialize( token, production = true )
		@caller = Call.new( token, production )
	end

	def token=( token )
		@caller.token = token		
	end

	def ebay_time
		@caller.make_shop_call 'GeteBayTime'
	end

	def find_products( keywords, page = 1, domain = nil )

		if keywords.is_a? Fixnum
			keywords = "<ProductID type='Reference'>#{keywords}</ProductID>"
		else
			keywords = "<QueryKeywords>#{keywords}</QueryKeywords>"
		end

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

		@caller.make_shop_call caller, body

	end # find_products


	# dateTime YYYY-MM-DDTHH:MM:SS.SSSZ (e.g., 2004-08-04T19:09:02.768Z)

	def verify_add_item( vars )

		vars[:buy_it_now_price] = '' # Only used with Auction. Must check for min percentage first
			# To find BuyItNow minimum percentage above start price when auction
			# 	caller GetEbayDetails
			# 		DetailName = ListingStartPriceDetails
			# 		['ListingStartPriceDetails.MinBuyItNowPricePercent']

		vars[:condition_description] = '' # Small section to futher describe the condition. Max 1000 chars

		vars[:condition_id] = '' # numeric ID
			# To find caller GetCategoryFeatures
			# 	['ConditionValues']

		vars[:description] = '' #html

		vars[:dispatch_time] = ''

		vars[:item_specifics] = ''
			# Find by using GetCategorySpecifics

		vars[:best_offer_auto_accept] = ''
		vars[:best_offer_minimum] = ''

		vars[:duration] = ''
			# Find legal values with GetCategoryFeatures
			# 							DetailLevel = ReturnAll
			# 							['ListingDurations']

		vars[:list_type] = '' # FixedPriceItem or Chinese

		vars[:paypal_email] = ''

		vars[:picture_urls] = ''
		# List of URLs (in tags) after upload to ebay
		# 		      <PictureURL></PictureURL>

		vars[:category] = '' # Category ID
		vars[:catalog] = ''

		vars[:quantity] = ''

		vars[:return_policy] = ''
=begin RETURN POLICY
			  <Description></Description>
		      <RefundOption>MoneyBack</RefundOption> # check with GeteBayDetails DN = ReturnPolicyDetails.Refund.RefundOption
		      <RestockingFeeValueOption>NoRestockingFee</RestockingFeeValueOption> # Percent_10
		      <ReturnsAcceptedOption>ReturnsAccepted</ReturnsAcceptedOption> # ReturnsNotAccepted
		      <ReturnsWithinOption>Days_14</ReturnsWithinOption> # Days_30
		      <ShippingCostPaidByOption>Buyer</ShippingCostPaidByOption>
		      <WarrantyDurationOption>Monthes_3</WarrantyDurationOption>
		      <WarrantyOfferedOption>WarrantyOffered</WarrantyOfferedOption>
		      <WarrantyTypeOption>DealerWarranty</WarrantyTypeOption> # ReplacementWarranty
=end

		vars[:schedule_time] = '<ScheduleTime> dateTime </ScheduleTime>'

		#		      <ExcludeShipToLocation> string </ExcludeShipToLocation>

		vars[:price] = ''

		vars[:store_category1] = ''
		vars[:store_category2] = ''

		caller = 'VerifyAddItem'
		body = <<-END
		  <Item>
		     <UUID> UUIDType (string) </UUID>
		  	<SKU> cutom data</SKU>
		    <ApplicationData>custom data</ApplicationData>
		    <PrivateNotes></PrivateNotes>
		    <AutoPay>true</AutoPay>
		    <BestOfferDetails>
		      <BestOfferEnabled>true</BestOfferEnabled>
		    </BestOfferDetails>
		    <BuyerRequirementDetails>
		      <MaximumBuyerPolicyViolations>
		        <Count>3</Count>
		        <Period>Days_180</Period>
		      </MaximumBuyerPolicyViolations>
		      <MaximumUnpaidItemStrikesInfo>
		        <Count>3</Count>
		        <Period>Days_180</Period>
		      </MaximumUnpaidItemStrikesInfo>
		      <ShipToRegistrationCountry>true</ShipToRegistrationCountry>
		    </BuyerRequirementDetails>
		    <DisableBuyerRequirements>false</DisableBuyerRequirements>
		    <BuyItNowPrice currencyID="USD">#{vars[:buy_it_now_price]}</BuyItNowPrice>
		    <CategoryBasedAttributesPrefill>true</CategoryBasedAttributesPrefill>
		    <CategoryMappingAllowed>false</CategoryMappingAllowed>
		    <ConditionDescription>#{vars[:condition_description]}</ConditionDescription>
		    <ConditionID>#{vars[:condition_id]}</ConditionID>
		    <Country>US</Country>
		    <Currency>USD</Currency>
		    <Description>#{vars[:description]}</Description>
		    <DispatchTimeMax>#{vars[:dispatch_time]}</DispatchTimeMax>
		    <HitCounter>Hidden</HitCounter>
		    <IncludeRecommendations>false</IncludeRecommendations>
		    <ItemSpecifics>
				#{vars[:item_specifics]}
		    </ItemSpecifics>
		    <ListingDetails>
		      <BestOfferAutoAcceptPrice currencyID="USD">#{vars[:best_offer_auto_accept]}</BestOfferAutoAcceptPrice>
		      <MinimumBestOfferPrice currencyID="USD">#{vars[:best_offer_minimum]}</MinimumBestOfferPrice>
		    </ListingDetails>
		    <ListingDuration>#{vars[:duration]}</ListingDuration>
		    <ListingType>#{vars[:list_type]}</ListingType>
		    <PaymentMethods>Paypal</PaymentMethods>
		    <PayPalEmailAddress>#{vars[:paypal_email]}</PayPalEmailAddress>
		    <PictureDetails>
		      <GalleryDuration>LifeTime</GalleryDuration>
		      <GalleryType>Featured</GalleryType>
		      <PhotoDisplay>PicturePack</PhotoDisplay>
		      #{vars[:picture_urls]}
		    </PictureDetails>
		    <PostalCode>59715</PostalCode>
		    <PrimaryCategory>
		      <CategoryID>#{vars[:category]}</CategoryID>
		    </PrimaryCategory>
		    <PrivateListing>false</PrivateListing>
		    <ProductListingDetails>
		      <IncludePrefilledItemInformation>false</IncludePrefilledItemInformation>
		      <IncludeStockPhotoURL>false</IncludeStockPhotoURL>
		      <ProductReferenceID>#{vars[:catalog]}</ProductReferenceID>
		      <ReturnSearchResultOnDuplicates>true</ReturnSearchResultOnDuplicates>
		      <UseFirstProduct>false</UseFirstProduct>
		      <UseStockPhotoURLAsGallery>true</UseStockPhotoURLAsGallery>
		    </ProductListingDetails>
		    <Quantity>#{vars[:quantity]}</Quantity>
		    <ReturnPolicy>
		    	#{vars[:return_policy]}
		    </ReturnPolicy>
		    #{vars[:schedule_time]}

		    <ShippingDetails>
		      <InternationalShippingServiceOption>
		        <ShippingService> token </ShippingService>
		        <ShippingServiceAdditionalCost currencyID="CurrencyCodeType"> AmountType (double) </ShippingServiceAdditionalCost>
		        <ShippingServiceCost currencyID="CurrencyCodeType"> AmountType (double) </ShippingServiceCost>
		        <ShippingServicePriority> int </ShippingServicePriority>
		        <ShipToLocation> string </ShipToLocation>
		      </InternationalShippingServiceOption>
		      <PaymentInstructions> string </PaymentInstructions>
		      <PromotionalShippingDiscount> boolean </PromotionalShippingDiscount>
		      <RateTableDetails> RateTableDetailsType
		        <DomesticRateTable> string </DomesticRateTable>
		        <InternationalRateTable> string </InternationalRateTable>
		      </RateTableDetails>
		      <SalesTax> SalesTaxType
		        <SalesTaxPercent> float </SalesTaxPercent>
		        <SalesTaxState> string </SalesTaxState>
		        <ShippingIncludedInTax> boolean </ShippingIncludedInTax>
		      </SalesTax>
		      <ShippingDiscountProfileID> string </ShippingDiscountProfileID>
		      <ShippingServiceOptions> ShippingServiceOptionsType
		        <FreeShipping> boolean </FreeShipping>
		        <ShippingService> token </ShippingService>
		        <ShippingServiceAdditionalCost currencyID="CurrencyCodeType"> AmountType (double) </ShippingServiceAdditionalCost>
		        <ShippingServiceCost currencyID="CurrencyCodeType"> AmountType (double) </ShippingServiceCost>
		        <ShippingServicePriority> int </ShippingServicePriority>
		        <ShippingSurcharge currencyID="CurrencyCodeType"> AmountType (double) </ShippingSurcharge>
		      </ShippingServiceOptions>
		      <!-- ... more ShippingServiceOptions nodes allowed here ... -->
		      <ShippingType> ShippingTypeCodeType </ShippingType>
		    </ShippingDetails>
		    <ShippingPackageDetails> ShipPackageDetailsType
		      <MeasurementUnit> MeasurementSystemCodeType </MeasurementUnit>
		      <PackageDepth> MeasureType (decimal) </PackageDepth>
		      <PackageLength> MeasureType (decimal) </PackageLength>
		      <PackageWidth> MeasureType (decimal) </PackageWidth>
		      <ShippingIrregular> boolean </ShippingIrregular>
		      <ShippingPackage> ShippingPackageCodeType </ShippingPackage>
		      <WeightMajor> MeasureType (decimal) </WeightMajor>
		      <WeightMinor> MeasureType (decimal) </WeightMinor>
		    </ShippingPackageDetails>
		    <ShippingServiceCostOverrideList> ShippingServiceCostOverrideListType
		      <ShippingServiceCostOverride> ShippingServiceCostOverrideType
		        <ShippingServiceAdditionalCost currencyID="CurrencyCodeType"> AmountType (double) </ShippingServiceAdditionalCost>
		        <ShippingServiceCost currencyID="CurrencyCodeType"> AmountType (double) </ShippingServiceCost>
		        <ShippingServicePriority> int </ShippingServicePriority>
		        <ShippingServiceType> ShippingServiceType </ShippingServiceType>
		        <ShippingSurcharge currencyID="CurrencyCodeType"> AmountType (double) </ShippingSurcharge>
		      </ShippingServiceCostOverride>
		      <!-- ... more ShippingServiceCostOverride nodes allowed here ... -->
		    </ShippingServiceCostOverrideList>
		    <ShippingTermsInDescription> boolean </ShippingTermsInDescription>
		    <ShipToLocations> string </ShipToLocations>
		    <!-- ... more ShipToLocations values allowed here ... -->

		    <Site>0</Site>
		    <StartPrice currencyID="USD">#{vars[:price]}</StartPrice>
		    <Storefront>
		      <StoreCategory2ID>#{vars[:store_category2]}</StoreCategory2ID>
		      <StoreCategoryID>#{vars[:store_category1]}</StoreCategoryID>
		    </Storefront>
		    <Title>#{vars[:title]}</Title>
		  </Item>
		  <ErrorHandling>FailOnError</ErrorHandling>
		  <ErrorLanguage>en_US</ErrorLanguage>
		  <WarningLevel>High</WarningLevel>
		END

	end # verify_add_item


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

	def upload_pictures( photos )
		
		responses = Array.new

		photos.each do |name, path|
			responses.push @caller.upload_picture( name, path )
		end


		if responses.is_a? NilClass
			nil
		elsif responses.size == 1
			responses.last
		else
			responses
		end

	end # upload_pictures

end # Courier

orthus_tech_token = 'AgAAAA**AQAAAA**aAAAAA**AaJ4VQ**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6AFkIOnD5WKoAqdj6x9nY+seQ**W8oCAA**AAMAAA**ZPA6X9PG7HZ1yZZFO94/Ntq2ks/p7GS6Ke3yf80Uql7ow77sMKOZkH0vIP275Ho36JKbyu5brwSEzENty/NZFgsVo6Dbik0c7VFAfr8KobRiUVwD8T+0e5rsSz/7wsAO4gX6V0O1YYLX95OwZx0dsMA7OCpuXh32HPhDrzWnjEfXrpFiSDKQ5c287U6aeSNRBziInqqWpvdj9JxeeIUs61rx5exQqKpAKCdNoElnvMfC2SMbWkV83xUaH5xqnYVe2VUNuQZvFGkh/KZIWLsssC/Dexrcg31iM+aidVIj83A7pfIWNkgM0C5ZPiPjEq//YWM0gS6NIoFYgyvGxpq2mw+KrsIxxLdMxlTx4YWaVDfKz7n8VUm0ozKioXGaQrbwPodHY4a/Uw6Cbv77ChTho7hzRc9bNqznNkVrv4tKthNbDAT1HN7TVL0M9DoahywlnzPPQj5kyuKCUC+D9bADjEtKTLTk/9TOn+OwTs1M6aVxJajo22r7CpxnQgQQL3OyViPVKAzukDUyKAQ9RznV5I9Lu+9SVBv7Xwb2uRS69qipDy/jOm092kOhZjl8GfD+eqlXj66WwkPbHlz/wQFxhow7Td5Lmn24qCTQId6192W/0AlduIk7QlPxgkLdRVn5Lq/REXvFiyM37OIpA+UL08kPcTALd6hXMWAXqWn10FjCe12mhJi1ibWp6sWmx+xk5OQEfilmArQFZsjCBje2KReIIrNGPJcJnpT+VsUljcHoRKTr6rH7KOi9imjxqvMo'
buyer_token = 'AgAAAA**AQAAAA**aAAAAA**kD8lVQ**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4GhDZWGpQ2dj6x9nY+seQ**/mMDAA**AAMAAA**2GScRUabHVT/RRkzlq4kTR6OJsKE/n2kiL9DthmMgbfszMKfzxIWQYj4PQ19f1UFdSpQ/a+4zA1ekphWVfQEqG1iFqFj+kbKnO84EjA2lXmYq9IWxyTyxedd96VQhI4hfsc0ot3T6pAGjof/wBPiaetTAZdySPbhni7nUe9goy28YHL+wSC8Rbce9vO2vlnuscE0PEFlDHZ6uCr9uijGprAlmAHgFqYn5mex7llOJG59EVswsFcVKDsVihgQJHqUKXqrslsA/9KbQrLLo5I97c2ePelaXKKrZXyuj3KW6rit2fRVfUbzxG1ADse0c1qQtQrDZV3ZNuxzQJh4d+xd2X7HqqsacU3ruxQoMfss9ea09AbW/UUhbS/OBs8G/Nez8C5j0BDHQDNXKym0MS9lH+2Us0JDwxTG1EvYXquj9SKUkOoFu+fWSi2gFtBJn+I9Unz8e67nSA6lYkJ66STgV4aL3XT7gVIQZmql0I6qjPtcvZSi3ym0bBNwM5hGKYk6fUyEKhxw/AN+RvRhRaj1GPyMtEM4NIKBpOiTQ5q1/a8xxoiPd4Z0qNRM0y9Bdlv3YqzphRJ0FZYL6q6E7S0mOVJuEQOXLofD/PjFaHY3eQTvNJC/3FoVFtXNLSzUcfIhKzT9sl7OIPTqSKQ1LYOe4ERocPtML/ag1nIs8ETCefCL82DyMsxRroDFIgl8I4SsllYBg/vlmLvPiMVU6XPqkHw5rUuFD/ARHc8XZyx7q0yloyO+7ejXbQBm290ykKQT'
seller_token = 'AgAAAA**AQAAAA**aAAAAA**gzqAVQ**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4GhDZiCoA6dj6x9nY+seQ**/mMDAA**AAMAAA**g8zWPzS6q0dMf0j0kt3VtE5wRbh0A6yhTP/xmS4PvGLZJpvgaTdteKRoS/c1aELoJXg+Z+83GW32PLCvS/WDEfu3gSs+cVR48cTw8ipS0J243zM1pbahGMP7IdIj7D5+auoDptcrqWCTBZbiGE5Efvb5MIiOYpmb97sI4WCelRMTGoachyE5U6sSj9nf79450iC8LNiaFAv6tC1Dk7UHzFTnoo10uj/8yQb8iu79k9Yki2Zhj1aKqF2eD+gjlkJqQUEhv5aifXe4mkFiz77xlCU82aOTne0nNjO1RNalZUCp3jylxL3blL6HyEm7SMy3IhQYt448DfoRhdejyBWU3fXNBhlTXiPxU4AJBan2lSJ5OPONrOGFop+1i9jPlGZxKPDhrkF3bbQ3/7iC7lUXGuucSaijs0Ud/OxEA9y+6VkabDtdhwk6M3YETscAf9797BZw5YzlEvEdmmQV3xDmC9gzEl/s8GkH0Yb4c2u0DPd+uf4DdqHY9fjuajElc2xjCWfWnCvWRHRNxKvJ4x6hwGWdTouVBlwHP+sPT0lnozu8B+QRWxAli6kECkYkErQyPk7hQvPOiV19LF9ur/gfFKYRnH0zHRsuvgN0uKT762yH6vyFaob8ePgbZACRwk+ioviS1mPlgriainvyk3Xwvu/aMXFG/scG7GXNOzfXUl2NQsR7z4Hw66jvB8Z4tGgspKF5zYx/kQ9fCTM56hou2MRR6WvrMfeOhzoOPF9mgudeSafQaw+PthKgEsCkpC87'

c = Courier.new( orthus_tech_token )
#puts c.get_active