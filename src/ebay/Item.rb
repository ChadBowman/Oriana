


class Item

	STATUS = ['Sold', 'Listed', 'Inventory']

	attr_accessor 	:id,
					:sku,
					:title,
					:price,
					:quantity,
					:category,
					:picture_urls,
					:list_duration,
					:dispatch_time,
					:condition_description,
					:description,
					:condition_id,
					:list_type,
					:buy_it_now_price,
					:best_offer,
					:best_offer_accept,
					:best_offer_decline,
					:immediate_payment,
					:store_category1,
					:store_category2, 
					:status,
					:upc

	def get_var_hash

		vars = Hash.new
		vars[:id] = @id
		vars[:sku] = @sku
		vars[:title] = @title
		vars[:price] = @price
		vars[:quantity] = @quantity
		vars[:category] = @category
		vars[:picture_urls] = @picture_urls
		vars[:duration] = @list_duration
		vars[:dispatch_time] = @dispatch_time
		vars[:condition_description] = @condition_description
		vars[:description] = @description
		vars[:condition_id] = @condition_id
		vars[:list_type] = @list_type
		vars[:buy_it_now_price] = @buy_it_now_price
		vars[:best_offer] = @best_offer
		vars[:best_offer_accept] = @best_offer_accept
		vars[:best_offer_decline] = @best_offer_decline
		vars[:immediate_payment] = @immediate_payment
		vars[:store_category1] = @store_category1
		vars[:store_category2] = @store_category2
		vars[:upc] = @upc

		vars
		
	end

end