# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2015 Orthus Technology
# License::   Distributes under the same terms as Ruby

require 'yaml'
require_relative 'src/gui/Console'
require_relative 'src/Courier'
require_relative 'src/Inventory'
require_relative 'src/Coin'
require_relative 'src/Utility'

# Parent Class for ORIANA
class Orthus

	# Call this class method to start the program
	def self.start

		##### LOAD SAVE FILE
		Thread.new do

			# String to read YAML
			str = String.new

			# For each line in file
			# concat the line to our string
			# 	(Apparently this is a non-slurp way to read a file)
			IO.foreach('saves/session.or') do |line|
				str += line
			end

			# Create the current session
			@s = YAML.load str
			# Create courier for making Ebay calls
			courier = Courier.new C::PROFILES[ @s.profile ].token, C::PROFILES[ @s.profile ].production

		end # load save file

		# variable for managing Console input state. Set to standard for normal action.
		state = :standard

		# Create the console
		# Block: All actions for input
		@console = Console.new( 30, 120, 'Oriana') do |input, out|

			# Input STATE switch
			case state
			# Standard input
			when :standard
				case input.value

				###########################################################################################################
				##### PURCHASE ASSEMBLY
				when /^ /

				###########################################################################################################
				##### PROFILE ACTIONS
				when /^set profile/													# SET PROFILE
					x = input.get_vars( 'set profile' ).to_sym						# grab profile name
					
					if C::PROFILES[x].is_a? NilClass								# Make sure it exists
						out.prompt "Profile #{x} does not exist."
						
					else
						@s.profile = x												# Set the new profile
						out.prompt "Profile set to: #{x}."
					end

				when /^show profile/												# SHOW PROFILE
					out.prompt "Profile: #{@s.profile}"								# display the current profile

				###########################################################################################################
				##### COLOR/QUALITY ACTIONS
				when /^create (color|quality) list/									# CREATE LIST
					if input.value.include? 'color'									# color
						vars = input.get_vars( 'create color list' )				# gather variables

						if vars.empty? 												# argument format requested
							out.prompt '_ name, color 1, color 2, ...'
							@console.in.insert 0, 'create color list '
						elsif !vars.is_a? Array 									# user only submitted a name
							out.prompt 'You must have at least 1 color.'
						else
							name = vars.first										# snag the name
							@s.color_lists[ name ] = vars[ 1, vars.length - 1 ]		# input the rest into session hash
							out.prompt "Color list #{name} added."					# output results
						end

					else															# quality
						vars = input.get_vars( 'create quality list' )				# gather variables

						if vars.empty? 												# argument format requested
							out.prompt '_ name, quality 1, quality 2, ...'
							@console.in.insert 0, 'create quality list '
						elsif !vars.is_a? array 									# user only submitted a name
							out.prompt 'You must have at least 1 quality.'
						else	
							name = vars.first										# snag the name
							@s.quality_lists[ name ] = vars[ 1, vars.length - 1 ]	# input the rest into session hash
							out.prompt "Quality list #{name} added."				# output results
						end
					end

				when /^add colors? to/												# ADD COLORS TO LIST
					vars = input.get_vars( 'add color to' )							# gather variables
					name = vars.first												# snag name of list to update
					vars = vars[ 1, vars.length - 1 ]								# snag colors	

					vars.each do |color|											# For each color
						@s.color_lists[ name ] << color 							# Add it color list
					end

					# When a new template is created, an availible color list
					# is passed through. Those lists need to be updated if a new
					# color is added to it.
					@s.inventory.update_color( name, @s.color_lists[ name ] ) 		# Update color lists in templates

					out.prompt "Colors added to #{name}."							# Output results

			
				when /^delete (color|quality) list/									# DELETE LIST
					if input.value.include? 'color'									# color
						var = input.get_vars( 'delete color list' )					# gather name
						@s.color_lists.delete var 									# delete hash from session

						# Deleted lists must be removed from templates which have
						# that list. However, Assemblies which use a color in the 
						# deleted list will have that color grandfathered-in.
						@s.inventory.update_color( name, nil )						# delete list from templates

					else															# quality
						var = input.get_vars( 'delete quality list' )				# gather name
						@s.quality_lists.delete var 								# delete hash from session
					end

					out.prompt "#{var} deleted."									# Output results

				when /^delete \w+ from \w+/ 										# DELETE COLOR OR QUALITY
					vars = input.value.gsub( /(delete |from )/, '' ).split( ' ' ) 	# Extract variables
					vars.map! do |element|
						element.gsub( '_', ' ')
					end

					if vars.length != 2 											# Check formatting
						out.prompt 'Invalid number of variables.'
						return
					end

					colors = @s.color_lists[ vars[1] ] 								# Grab from lists
					quals = @s.quality_lists[ vars[1] ]

					if colors.is_a? NilClass and quals.is_a? NilClass 				# Check list selection
						out.prompt "#{vars[1]} is not a color or quality list."
						return
					end

					if colors.is_a? Array 											# Delete color
						colors = colors.delete vars[0]
						if colors.is_a? NilClass
							out.prompt "#{vars[0]} not found." 
							return
						end
					end

					if quals.is_a? Array 											# Delete quality
						quals = quals.delete vars[0] 
						if quals.is_a? NilClass
							out.prompt "#{vars[0]} not found."
							return
						end
					end

					if colors.is_a? Array and quals.is_a? Array 					# Output results
						out.prompt "#{vars[0]} deleted from both #{vars[1]} lists."
					else
						out.prompt "#{vars[0]} deleted from #{vars[1]}."
					end

				when /^show (color|quality) lists/									# SHOW LISTS
					str = String.new 												# output string

					if input.value.include? 'color' 								
						@s.color_lists.each do |key, value| 						# for each color list
							str += "#{@s.color_list_to_s( key )}\n"  				# concat to return string
						end

					else
						@s.quality_lists.each do |key, val| 						# for each quality list
							str += "#{@s.quality_list_to_s( key )}\n" 				# concat to return string
						end
					end

					out.post str.chop 												# Post string with last newline chopped

				###########################################################################################################
				##### TEMPLATE MANAGEMENT
				when /^add template/ 												# ADD TEMPLATE
					vars = input.get_vars( 'add template' ) 						# gather vars

					if vars.empty? 													# when help requested
						if @s.inventory.templates.empty?
							out.prompt 'You must create a template first.'
							return
						end
																					# display help
						out.prompt '_ parent, name, color list?, quality list?, quantity?, required?, atom?'
						out.post @s.inventory.templates_to_s
						out.post_sub @s.lists_to_s
						@console.in.insert 0, 'add template '
						return
					end

					if @s.inventory.templates[ vars[0] ].is_a? NilClass 			# Check parent existence
						out.prompt "Parent template #{vars[0]} not found."
						return
					end

					parent = vars[0] 												# snag variables
					name = vars[1]
					colors = @s.inventory.templates[ parent ].availible_colors
					qualities = @s.inventory.templates[ parent ].availible_qualities
					quant = 1 														# set defaults
					requ = true
					atom = false

					if name =~ /^\d+$/ 												# adding already made part
				 		# When using a template ID instead of a name
				 		# that part is added to parent part map and the only
				 		# arguments allowed are required and atom
				 		unless vars[2].is_a? NilClass 								# If required argument exists				
				 			unless vars[2].is_a? TrueClass or vars[2].is_a? FalseClass
				 				out.prompt 'Invalid option for required.'
				 				return
				 			else
				 				requ = vars[2]
				 			end
				 		end

				 		unless vars[3].is_a? NilClass
				 			unless vars[3].is_a? TrueClass or vars[3].is_a? FalseClass
				 				out.prompt 'Invalid option for atom.'
				 				return
				 			else
				 				atom = vars[3]
				 			end
				 			
				 		end

				 																	# Add ID/req to parent's part map
				 		@s.inventory.templates[ parent ].part_map[name] = [requ, atom]	
				 		out.post @s.inventory.template_to_s parent 					# Post update
				 		@console.in.insert '0', "#{parent} " 						# Insert parent ID for speed
				 		out.prompt 'parent, name, color list?, quality list?, quantity?, required?, atom?'
				 		return
				 	end

					unless vars[2].is_a? NilClass 									# If imposing color list
						if @s.color_lists[ vars[2] ].is_a? NilClass 				# check for color list
							out.prompt 'Color List not found.' 						# return if not found
							return
						else
							colors = { vars[2] => @s.color_lists[ vars[2] ] }  # assign properly
						end
					end

					unless vars[3].is_a? NilClass 									# If imposing quality list
						if @s.quality_lists[ vars[3] ].is_a? NilClass 				# check for quality list
							out.prompt 'Quality List not found.' 					# return if not found
							return
						else														# assign properly
							qualities = { vars[3] => @s.quality_lists[ vars[3] ] }
						end
					end
					
					unless vars[4].is_a? NilClass 									# If imposing quantity
						begin
							quant = Integer( vars[4] )
							raise ArgumentError if quant < 1 						# Check for invalid quantities
						rescue ArgumentError
							out.prompt "Quantity needs to be an integer greater than 0."
							return
						end
					end

					unless vars[5].is_a? NilClass 									# If imposing required
						unless vars[5].is_a? TrueClass or vars[5].is_a? FalseClass  # check argument
							out.prompt 'Invalid option for required.'
							return
						else
							requ = vars[5] 											# If good, assign
						end
					end

					unless vars[6].is_a? NilClass
						unless vars[6].is_a? TrueClass or vars[6].is_a? FalseClass
							out.prompt 'Invalid option for atom.'
							return
						else
							atom = vars[6]
						end
						
					end
							
					id = @s.inventory.get_new_id 									# Assign new ID
																					# Add to inventory
					@s.inventory << Template.new( name, id, colors, qualities, quant ) 
					@s.inventory.templates[ parent ].part_map[ id ] = [requ, atom] 	# Add to parent part map
					out.prompt "#{id}|#{name} added."
					out.post @s.inventory.template_to_s parent						# display results

				when /^create template$/ 											# CREATE TEMPLATE
					out.prompt 'name, color list, quality list' 					# display arguments
					out.post_sub @s.lists_to_s										# Display list options
					state = :template  											# Set unput state

				when /^show templates detailed/ 									# SHOW TEMPLATES
					out.post @s.inventory.templates_to_s true 						# with details

				when /^show templates$/												# SHOW TEMPLATES
					out.post @s.inventory.templates_to_s							# display templates

				when /^delete template/ 											# DELETE TEMPLATE
					vars = input.get_vars( 'delete template' )

					result = @s.inventory.delete_template vars

					if result.is_a? NilClass 										# Display results
						out.prompt "#{vars} template not found."
					else
						out.prompt "#{vars}|#{result.name} deleted."
						out.post @s.inventory.templates_to_s
					end

				when /^edit template/												# EDIT TEMPLATE
					vars = input.get_flags( 'edit template' )	

					if vars == 'exit'
						@console.in.delete 0, 'end'
						return
					end		

					if vars.empty? 													# display argument options
						out.prompt '_ id -n name -u quantity -c colors -q qualities -d delete -ch child :[-r required -a atom]'
						out.post @s.inventory.templates_to_s true					# display templates
						out.post_sub @s.lists_to_s 									# display lists
						@console.in.insert 0, 'edit template ' 						# replace command
						return
					end

					id = input.get_vars( 'edit template' )[0] 						# snag ID

					if @s.inventory.templates[ id ].is_a? NilClass 					# check for valid ID, return if not
						out.prompt 'Parent Template doesn\'t exist.'
						return
					end

					parent = @s.inventory.templates[ id ] 							# snag parent Template

					unless vars['c'].is_a? NilClass 								
						if @s.color_lists[ vars['c'] ].is_a? NilClass
							out.prompt 'Not a valid color list.'
							return
						else
							colors = { vars['c'] => @s.color_lists[ vars['c'] ] }
						end
					end

					unless vars['q'].is_a? NilClass
						if @s.quality_lists[ vars['q'] ].is_a? NilClass
							out.prompt 'Not a valid quality list.'
							return
						else
							qualities = { vars['q'] => @s.quality_lists[ vars['q'] ] }
						end
					end

					unless vars['ch'].is_a? NilClass
						if @s.inventory.templates[ vars['ch'] ].is_a? NilClass
							out.prompt 'Child does not exist.'
							return
						end
					end

					unless vars['r'].is_a? NilClass
						unless vars['r'].is_a? TrueClass or vars['r'].is_a? FalseClass
				 			out.prompt 'Invalid option for required.'  				# invalid requirement argument, return
				 			return
				 		else
				 			req = vars['r']
				 		end

				 		if vars['ch'].is_a? NilClass
				 			out.prompt 'You must select a child Template.'
				 			return
				 		end
						
					end

					unless vars['a'].is_a? NilClass
						unless vars['a'].is_a? TrueClass or vars['a'].is_a? FalseClass
				 			out.prompt 'Invalid option for atom.'  					# invalid requirement argument, return
				 			return
				 		else
				 			atm = vars['a']
				 		end

				 		if vars['ch'].is_a? NilClass
				 			out.prompt 'You must select a child Template.'
				 			return
				 		end
						
					end

					unless vars['d'].is_a? NilClass
						if parent.part_map[ vars['d'] ].is_a? NilClass
							out.prompt "Template to delete must be a child of #{id}."
							return
						end
					end

					# All checks made, time to make changes
					parent.name = vars['n'] unless vars['n'].is_a? NilClass 				# replace name
					parent.quantity_needed = vars['u'] unless vars['u'].is_a? NilClass 		# replace quantity
					parent.availible_colors = colors unless vars['c'].is_a? NilClass		# replace color list
					parent.availible_qualities = qualities unless vars['q'].is_a? NilClass	# replace quality list
					parent.part_map[ vars['ch'] ][0] = req unless vars['r'].is_a? NilClass	# replace required
					parent.part_map[ vars['ch'] ][1] = atm unless vars['a'].is_a? NilClass 	# replace atom
					parent.part_map.delete( vars['d'] ) unless vars['d'].is_a? NilClass		# delete child

					out.post @s.inventory.template_to_s id, true 							# display changes
					out.prompt '_ id -n name -u quantity -c colors -q qualities -d delete -ch child :[-r required -a atom]'
					@console.in.insert 0, 'edit template ' 									# replace command

				###########################################################################################################
				##### INVALID INPUT
				else
					out.prompt 'Command unrecognized.' 								# command unknown

				end # standard input

			###########################################################################################################
			# Input for template creation
			when :template

				case input.value
				when /^exit/ 														# EXIT TEMPLATE CREATION
					out.prompt 'Exited template creation.' 
					state = :standard 												# set state back

				when /^\d+ / 														# CREATE CHILD TEMPLATE
					
					if root_id.is_a? NilClass 										# Check to make sure parent Template was created
						out.prompt 'Create a parent template first.' 				# If not, return
						return
					end

					vars = input.get_vars 											# gather variables
					if vars.length < 2 												# Check for minimum variables, return if not
						out.prompt "Invalid number of variables [#{vars.length}/2]."
				 		return
				 	end

				 	parent = vars[0] 												# snag parent ID	
				 	if @s.inventory.templates[ parent ].is_a? NilClass 				# Check parent exists, if not return
				 		out.prompt "Template #{parent} does not exist."
				 		return
				 	end

				 	name = vars[1] 													# snag name or ID
				 	req = true 														# Set default for requirement
				 	colors = @s.inventory.templates[ parent ].availible_colors 		# Set default (parent) color list
				 	quals = @s.inventory.templates[ parent ].availible_qualities 	# set default (parent) quality list
				 	quant = 1														# set default quantity (1)
				 	atom = false 													# set default atom

				 	if name =~ /^\d+$/ 												# adding already made part
				 		# When using a template ID instead of a name
				 		# that part is added to parent part map and the only
				 		# arguments allowed are required and atom
				 		unless vars[2].is_a? NilClass 								# If required argument exists				
				 			unless vars[2].is_a? TrueClass or vars[2].is_a? FalseClass
				 				out.prompt 'Invalid option for required.' 
				 				return
				 			else
				 				req = vars[2]
				 			end
				 		end

				 		unless vars[3].is_a? NilClass 								# If atom argument exists
				 			unless vars[3].is_a? TrueClass or vars[3].is_a? FalseClass
				 				out.prompt 'Invalid option for atom.'
				 				return
				 			else
				 				atom = vars[3]
				 			end
				 			
				 		end

				 		@s.inventory.templates[ parent ].part_map[name] = [req, atom]	# Add ID/req to parent's part map
				 		out.post @s.inventory.template_to_s root_id 				# Post update
				 		@console.in.insert '0', "#{parent} " 						# Insert parent ID for speed
				 		out.prompt 'parent, name, color list?, quality list?, quantity?, required?, atom?'
				 		return
				 	end

				 	unless vars[2].is_a? NilClass 									# If color list arugment exists
				 		if @s.color_lists[ vars[2] ].is_a? NilClass 				# Check if color list exists. If not, return
							out.prompt "#{vars[2]} is not a valid color list."
							return
						end

						# Tempaltes have colors and qualities in a hash with only one element
						# so which color list was used can be identified by the key.
						# 	name => color list array
						colors = { vars[2] => @s.color_lists[ vars[2] ] } 			# set colors to special Hash
				 	end

				 	unless vars[3].is_a? NilClass 									# If quality list arugment exits
				 		if @s.quality_lists[ vars[3] ].is_a? NilClass 				# Check if quality list exists. If not, return
							out.prompt "#{vars[3]} is not a valid quality list."
							return
						end

						quals = { vars[3] => @s.quality_lists[ vars[3] ] } 			# set qualities to special Hash
				 	end

				 	unless vars[4].is_a? NilClass 									# If quantity argument exists
				 		begin
				 			quant = Integer( vars[4] ) 								# Convert to Fixnum
				 			raise ArgumentError if quant < 1
				 		rescue ArgumentError 										# Check if valid quantity, if not return
				 			out.prompt 'Quantity argument should be a number and > 0.'
				 			return
				 		end
				 	end

				 	unless vars[5].is_a? NilClass 									# If require argument exists
				 		unless vars[5].is_a? TrueClass or vars[5].is_a? FalseClass
				 			out.prompt 'Invalid option for required.'  				# invalid requirement argument, return
				 			return
				 		else
				 			req = vars[5]
				 		end
				 	end

				 	unless vars[6].is_a? NilClass 									# If atom argument exists
				 		unless vars[6].is_a? TrueClass or vars[6].is_a? FalseClass
				 			out.prompt 'Invalid option for atom.'  				# invalid requirement argument, return
				 			return
				 		else
				 			atom = vars[6]
				 		end
				 	end

				 	if !@s.inventory.templates[ name ].is_a? NilClass 				# Check if name is actually an ID
				 		id = name 													# snag id
				 		@s.inventory.templates[ parent ].part_map[id] = [req, atom]	# Add template to parent part map
				 		out.post @s.inventory.template_to_s root_id 				# Post results
				 		@console.in.insert '0', "#{parent} " 						# Insert parent ID for speed
				 		return 														# Break because we are finished
				 	end

				 	id = @s.inventory.get_new_id 									# Adding a new Tempalte, retrive new ID

				 	@s.inventory << Template.new( name, id, colors, quals, quant ) 	# Add new template to Inventory
				 	@s.inventory.templates[ parent ].part_map[id] = [req, atom]		# Add ID/req to parent's part map
				 	out.post @s.inventory.template_to_s root_id 					# Post update
				 	@console.in.insert '0', "#{parent} " 							# Insert parent ID for speed
				 	out.prompt 'parent, name, color list?, quality list?, quantity?, required?, atom?'


				else 																# CREATE ROOT TEMPLATE
					vars = input.get_vars 											# gather variables
					if vars.length != 3 											# check for correct number of inputs, return if not
				 		out.prompt "Invalid number of variables [#{vars.length}/3]."
				 		return
					end

					name = vars[0] 													# snag name
					colors = vars[1] 												# snag color list
					qualities = vars[2] 											# snag quality list

					if @s.color_lists[ colors ].is_a? NilClass 						# Check if color list exists, return if not
						out.prompt "#{colors} is not a valid color list."
						return

					elsif @s.quality_lists[ qualities ].is_a? NilClass 				# Check if quality list exists, return if not
						out.prompt "#{qualities} is not a valid quality list."
						return
					end

					# Tempaltes have colors and qualities in a hash with only one element
					# so which color list was used can be identified by the key.
					# 	name => color list array
					colors = { colors => @s.color_lists[ colors ] } 				# Set up special color Hash
					qualities = { qualities => @s.quality_lists[ qualities ] } 		# set up special quality Hash
					root_id = @s.inventory.get_new_id 								# get a new ID
					# Add new Template to Inventory
				 	@s.inventory << Template.new( name, root_id, colors, qualities )

					out.post @s.inventory.template_to_s root_id 					# Post update
					# Post arugments
					out.prompt 'parent, name, color list?, quality list?, quantity?, required?, atom?'
					@console.in.insert '0', "#{root_id} " 						 	# Insert parent id for speed

				end # template options

			end # special state

		end # self.start

		##### ADDITIONAL CONSOLE BINDINGS
		# Save session to file
		@console.root.bind('Control-s') do
			File.write 'saves/session.or', @s.to_yaml
			@console.out.prompt 'Saved'
		end

		# Display welcome screen	
		@console.out.insert 'end', C::WELCOME
		# Start Console's main thread
		@console.start

	end # initialize

end # Oriana

Oriana.start