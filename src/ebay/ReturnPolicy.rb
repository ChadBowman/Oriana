





class ReturnPolicy

	ACCEPTED = 'ReturnsAccepted'
	NOT_ACCEPTED = 'ReturnsNotAccepted'

	MONEY_BACK = 'MoneyBack'

	DAYS_30 = 'Days_30'
	DAYS_60 = 'Days_60'

	RESTOCK_FEE = ['NoRestockingFee', 'Percent_10', 'Percent_15', 'Percent_20']

	BUYER = 'Buyer'
	SELLER = 'Seller'

	@@number = 0

	attr_accessor :name, :description, :accepted, :option, :time_within, 
		:restock_fee, :shipping_paid_by

	def initialize( name = nil, description = nil )
		@@number += 1
		
		if name.nil?
			@name = "Return Policy #{@@number}"
		else
			@name = name
		end
	
		@description = description
		@accepted = ACCEPTED
		@option = MONEY_BACK
		@time_within = DAYS_30
		@restock_fee = RESTOCK_FEE[0]
		@shipping_paid_by = BUYER
	end

	# Setters
	def accepted=( x )

		@accepted = x if x == ACCEPTED or x == NOT_ACCEPTED
					
	end

	def option=( x )

		@option = x if x == MONEY_BACK
		
	end

	def time_within=( x )

		@time_within = x if x == DAYS_30 or x == DAYS_60
		
	end

	def restock_fee=( x )

		RESTOCK_FEE.each do |option|
			@restock_fee = x if x == option
		end
		
	end

	def shipping_paid_by=( x )

		@shipping_paid_by = x if x == BUYER or x == SELLER
		
	end

	#----------------------------------------------

	def to_XML

		<<-END
		<ReturnPolicy>
      		<RefundOption>#{@option}</RefundOption>
      		<RestockingFeeValueOption>#{@restock_fee}</RestockingFeeValueOption>
      		<ReturnsAcceptedOption>#{@accepted}</ReturnsAcceptedOption>
      		<ReturnsWithinOption>#{@time_within}</ReturnsWithinOption>
      		<ShippingCostPaidByOption>#{@shipping_paid_by}</ShippingCostPaidByOption>
    	</ReturnPolicy>
		END
		
	end

end # ReturnPolicy