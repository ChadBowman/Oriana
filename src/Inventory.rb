# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2015 Orthus Technology
# License::   Distributes under the same terms as Ruby

# Houses inventory of Assemblies and Templates to which Assemblies are derived from
class Inventory

	# +inventory+:: Hash of all parts. key => id
	# +templates+:: Hash of all templates. key => id
	attr_accessor :inventory, :templates

	def initialize
		self.inventory = Hash.new
		self.templates = Hash.new
	end

	# Searches Templates for next availible ID
	# IDs should never exceed 9 digits. Raises error if 10 or more.
	def get_new_id
		
		count = 0 		# Start at 0

		while true
			count += 1  # Increment
			# Break out of loop when ID found
			break if @templates[ count.to_s ].is_a? NilClass
		end

		# Raise error if out of range
		raise RangeError, "#{count} exceeds the planned range, may cause problems" if count.to_s.length > 9

		# Return id in String form
		count.to_s

	end # get_new_id

	# Add Assembly or Tempalte to appropriate Hash
	# 
	# Parameter:
	# +part+:: Assembly or Template to add to Inventory
	def <<( part )
		if part.is_a? Assembly
			@inventory[ part.id ] = part

		elsif part.is_a? Template
			@templates[ part.id ] = part
		end
	end

	# Removes template from main Hash and any associated part maps
	#
	# Parameter:
	# +id+:: ID of Template to remove
	def delete_template( id )
		# for each template
		@templates.each do |key, template|
			# make sure the Template is removed from the part map
			template.part_map.delete( id )
		end
		
		# remove Template from main Hash
		@templates.delete( id )

	end # delete_template

	# Returns string of templates in respective heiarchy
	#
	# Parameters:
	# +id+:: ID of root template
	# +space+:: space to create heiarchy effect (used recursivly)
	# +att+:: child attributes (used recursivly)
	def template_to_s( id, space = '', att = '' )

		# snag ID if tempalte passed in
		id = id.id if id.is_a? Template

		# string to return
		str = String.new
		# Snag template
		template = @templates[ id ]

		# unless template doesn't exist
		unless template.is_a? NilClass
			# show quantity if greater than 1
			quant = template.quantity_needed > 1 ? " (#{template.quantity_needed})" : ''
			# show attributes
			att = " [#{att}]" if att != ''
			# format line
			str += "%s%3s|%s%s%s" % [space, id, template.name, quant, att]
			# add some space for intent
			space += '  '

			# for each part in the part map
			template.part_map.each do |key, val|
				# produce attribute symbols for uncommons
				req = val[0] ? '' : 'N'
				atm = val[1] ? 'A' : ''
				# call method for each part in map
				str += "\n%s" % template_to_s( key, space, req + atm )
			end
		end

		# return result
		str

	end # template_to_s

	# Returns a string with the entire Template heiarchy
	def templates_to_s

		# Concatenate all root string representations.
		str = String.new
		collect_roots.each do |root|
			str += "#{template_to_s root.id}\n" 
		end
		
		# Return results without last newline
		str.chop

	end # templates_to_s

	# Checks all template's part maps for id, if no match is found,
	# returns true, otherwise false.
	#
	# Parameter:
	# +id+:: id of Template to check for root
	def template_root?( id )

		# for each template
		templates.each do |key, template|
			# false unless id is not found in template's part map
			return false unless template.part_map[id].is_a? NilClass
			# then keep going...
		end

		# No match found anywhere, return true
		true

	end # tempalte_root?

	# Returns array of all root Templates
	def collect_roots

		# Array to return
		roots = Array.new
		# For each template
		templates.each do |key, val|
			# Push to array if root
			roots << val if template_root? key
		end
		
		# Return results
		roots

	end # collect_roots

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
					:quantity_needed,				# Quantity of parts in assembly
					:part_map						# Hash id => [required, atom] of other templates
													# 	ID of child assembly
													# 	If the child is required to sell
													# 	If the assembly's children can be dismantled to use

	def initialize( name, id, colors, qualities, quantity = 1 )

		raise ArgumentError unless colors.is_a? Hash or colors.is_a? NilClass
		raise ArgumentError unless qualities.is_a? Hash or qualities.is_a? NilClass

		self.name = name
		self.id = id
		self.availible_colors = colors
		self.availible_qualities = qualities
		self.part_map = Hash.new
		self.quantity_needed = quantity
	end

	# Returns name of color list or nil if none.
	def get_color_list_name
		@availible_colors.keys[0]
	end

	# Returns name of quality list or nil if none.
	def get_quality_list_name
		@availible_qualities.keys[0]
	end

	# Makes sure id is always set as a String to it can be accessed 
	# properly in Hashes
	#
	# Parameter:
	# +id+:: new ID for Template
	def id=( id )
		if id.is_a? Fixnum
			@id = id.to_s
		else
			@id = id
		end
	end

	# Makes sure quanity is always a Fixnum for future operations.
	#
	# Parameter:
	# +quantity+:: quantity of parts needed in Template
	def quantity_needed=( quantity )
		if quantity.is_a? String
			@quantity_needed = Integer( quantity )
		elsif quantity.is_a? Fixnum
			@quantity_needed = quantity
		else
			raise ArgumentError
		end	
	end

	# Displays name and ID
	def to_s
		"#{@name} [#{@id}]"
	end

	# Checks inventory templates to see if any other template
	# has this one listed as child.
	#
	# Parameter:
	# +inventory+:: instance of inventory to check against
	def is_root?( inventory )
		inventory.template_root?( @id )
	end

	# Returns true if the part map is empty (there are no children)
	def is_leaf?
		self.part_map.empty?
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