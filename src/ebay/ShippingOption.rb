



require_relative '../utility/Coin'


class ShippingOption

	SERVICES = ['USPSMedia', 'USPSParcel', 'USPSFirstClass', 'USPSPriority', 
		'USPSExpressMail']

	PACKAGE_TYPES = ['PackageThickEnvelope', 'LargeEnvelope', 
		'Letter', 'USPSLargePack']

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
		@additional_cost = '0.00'
		@type = CALCULATED
		@region = DOMESTIC
		@package_type = PACKAGE_TYPES[0]
		@weight_major = '0'
		@weight_minor = '3'
	end


	def to_XML
		unless @cost.nil?
			c = "<ShippingServiceCost currencyID='USD'>#{@cost}</ShippingServiceCost>"
		end

		if @type == CALCULATED
			override = <<-END
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
		
		<<-END
		<ShippingDetails>
			<ShippingServiceOptions>
				<FreeShipping>#{@free}</FreeShipping>
				<ShippingService>#{@service}</ShippingService>
	 			<ShippingServicePriority>#{@priority}</ShippingServicePriority>
	 			#{c}
	 			<ShippingServiceAdditionalCost currencyID='USD'>#{@additional_cost}</ShippingServiceAdditionalCost>
	 		</ShippingServiceOptions>
 		</ShippingDetails>
 		#{override}
		END
	end

end
