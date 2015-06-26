
require 'yaml'

class Inventory

	attr_accessor :inventory, :templates # Hash id > product

	def initialize
		self.inventory = Hash.new
		self.templates = Hash.new
	end

	def get_new_id
		
		count = 0
		flag = true

		while flag
			count += 1
			flag = false if @templates[ count.to_s ].is_a? NilClass
		end

		raise RangeError, "#{count} exceeds the planned range, may cause problems" if count.to_s.length > 9

		count.to_s

	end

	def <<( part )
		if part.is_a? Assembly
			@inventory[ part.id ] = part

		elsif part.is_a? Template
			@templates[ part.id ] = part
		end
	end

	def template_to_s( id, space = '' )

		str = String.new
		template = @templates[ id ]

		unless template.is_a? NilClass
			str += "#{space}#{template.name} [#{id}]"

			template.part_map.each do |pair|
				str += "\n#{template_to_s( pair[0], space + '  ' )}"
			end
		end

		str
	end

	def update_color( name, colors )
		@templates.each do |template|

			if !template.availible_colors[ name ].is_a? NilClass
				if colors.is_a? NilClass
					template.availible_colors = nil
				else
					template.availible_colors.values[0] = colors
				end
			end

		end

	end # update_color

end

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
					:sold_date,						# Date sold
					:item_id						# Item ID assigned by Ebay
					

end

module Buyable

	attr_accessor	:purchase_date,					# Date purchased
					:purchase_price					# Price of purchase (per unit)

end

class Template

	attr_accessor	:name, 							# Name of assembly (non-unique)
					:id, 							# Numeric, unique ID
					:availible_colors, 				# Hash of Array of colors to choose from
					:availible_qualities, 			# Hash of Array of qualities to chooose from
					:part_map						# Array with id-required pairs of other templates
			

	def initialize( name, id, colors, qualities )
		self.name = name
		self.id = id
		self.availible_colors = colors
		self.availible_qualities = qualities
		self.part_map = Array.new
	end

	def to_s
		"#{@name} [#{@id}]"
	end

	def branch( color, quality )

		if @availible_colors.values[0][ color ].is_a? NilClass
			raise ArgumentError, "#{color} is not availible for #{@name} [#{@id}]"
		elsif @availible_qualities.values[0][ quality ].is_a? NilClass
			raise ArgumentError, "#{quality} is not availible for #{@name} [#{@id}]"
		else
			assem = Assembly.new( @name, @id, @colors, @qualities, @map, color, quality )
		end
		
	end

end

class Assembly < Template

	include Sellable
	include Buyable

	attr_accessor	:quantity,
					:color, 
					:quality,
					:parts,
					:status				# Availible, Reserved, Listed, Sold

	def initialize( name, id, colors, qualities, map, color, quality )
		super( name, id, colors, qualities, map )
		
		self.color = color
		self.quality = quality
		
	end


end