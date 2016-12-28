



require_relative '../utility/Coin'


class ShippingOption

	module Services
		MEDIA = 'USPSMedia'
		PARCEL = 'USPSParcel'
		FIRST_CLASS = 'USPSFirstClass'
		PRIORITY = 'USPSPriority'
		EXPRESS = 'USPSExpressMail'
		FIRST_CLASS_INT = 'USPSFirstClassMailInternational'
	end

	module PackageTypes
		PACKAGE = 'PackageThickEnvelope'
		LARGE_ENVELOPE = 'LargeEnvelope'
		LETTER = 'Letter'
		LARGE_PACKAGE = 'USPSLargePack'
	end	


	CALCULATED = 'Calculated'
	FLAT = 'Flat'

	DOMESTIC = 'Domestic'
	INTERNATIONAL = 'International'

	@@number = 0

	attr_accessor :name, :free, :service, :cost, :additional_cost, :priority, 
		:type, :weight_minor, :weight_major, :region, :package_type

	def initialize( name = nil )
		@@number += 1

		@name = "Shipping Option #{@@number}" if name.nil?
		@free = false
		@cost = '0.00'
		@additional_cost = '0.00'
		@type = CALCULATED
		@region = DOMESTIC
		@package_type = PackageTypes::PACKAGE
		@weight_major = '0'
		@weight_minor = '3'
	end


	def to_XML( *additional )

		if @region == INTERNATIONAL and additional.nil?
			throw StandardError, "Cannot use an international shipping type without a domestic option."
		end

		cost = "<ShippingServiceCost currencyID='USD'>#{@cost}</ShippingServiceCost><ShippingServiceAdditionalCost currencyID='USD'>#{@additional_cost}</ShippingServiceAdditionalCost>" if @type == FLAT

		if @region == INTERNATIONAL


			details = <<-END
			<InternationalShippingServiceOption>
	 			<ShippingService>#{@service}</ShippingService>
	 			<ShippingServicePriority>{@priority}</ShippingServicePriority>
	 			#{cost}
	 			<ShipToLocation>Worldwide</ShipToLocation>
	 		</InternationalShippingServiceOption>
			END

		else
			details = <<-END
			<ShippingServiceOptions>
				<FreeShipping>#{@free}</FreeShipping>
				<ShippingService>#{@service}</ShippingService>
	 			<ShippingServicePriority>#{@priority}</ShippingServicePriority>
	 			#{cost}
	 		</ShippingServiceOptions>
			END
		
		end


		additional.each do |option|

			if @type == FLAT
				cost = "<ShippingServiceCost currencyID='USD'>#{option.cost}</ShippingServiceCost><ShippingServiceAdditionalCost currencyID='USD'>#{option.additional_cost}</ShippingServiceAdditionalCost>" 
			end

			if option.region == DOMESTIC

				details << <<-END
				<ShippingServiceOptions>
					<FreeShipping>#{option.free}</FreeShipping>
					<ShippingService>#{option.service}</ShippingService>
	 				<ShippingServicePriority>#{option.priority}</ShippingServicePriority>
	 				#{cost}
	 			</ShippingServiceOptions>
				END

			elsif option.region == INTERNATIONAL

				details << <<-END
				<InternationalShippingServiceOption>
					<ShippingService>#{option.service}</ShippingService>
	 				<ShippingServicePriority>#{option.priority}</ShippingServicePriority>
	 				#{cost}
					<ShipToLocation>Worldwide</ShipToLocation>
	 			</InternationalShippingServiceOption>
				END

			end

		end

		<<-END
		<ShippingDetails>
			<GlobalShipping>true</GlobalShipping>
			<ShippingType>#{@type}</ShippingType>
			#{details}
 		</ShippingDetails>
 		<ShippingPackageDetails>
	      	<MeasurementUnit>English</MeasurementUnit>
	      	<PackageDepth unit="in">2</PackageDepth>
	      	<PackageLength unit="in">12</PackageLength>
	      	<PackageWidth unit="in">12</PackageWidth>
	      	<ShippingIrregular>false</ShippingIrregular>
	      	<ShippingPackage>#{@package_type}</ShippingPackage>
	      	<WeightMajor unit="lbs">#{@weight_major}</WeightMajor>
	      	<WeightMinor unit="oz">#{@weight_minor}</WeightMinor>
	    </ShippingPackageDetails>
		END
	end

end