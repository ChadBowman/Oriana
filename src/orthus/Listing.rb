# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2015 Orthus Technology
# License::   Distributes under the same terms as Ruby

module Sellable

	attr_accessor   :list_category,					# Category ID
					:list_catalog,					# Catalog ID
					:list_price,					# Currently listed price
					:list_quantity,					# Current quantity listed
					:list_condition_description, 	# Small description on condition
					:list_condition_id,				# Category-specific ID
					:list_title,					# Listing title
					:list_BO_accept,				# Best offer auto accept
					:list_BO_minimum,				# Best offer minimum price allow
					:list_dispatch_time,			# Dispatch time
					:list_duration,					# List duration
					:list_type,						# Auction or Fixed 
					:list_date,						# Date first listed
					:list_photos,					# Array? of photo URLs
					:list_return_policy,			# Return policy (OBJECT)
					:list_shipping_methods,			# Shipping Methods (OBJECT)
					:list_price_history,			# Date-price hash
					:list_item_id,					# Item ID assigned by Ebay
					:sold_date						# Date sold

					
end

module Buyable

	attr_accessor	:purchase_date,					# Date purchased
					:purchase_price,				# Price of purchase (per unit)
					:purchase_item_id 				# Item ID assigned by Ebay

end