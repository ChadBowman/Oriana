# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2015 Orthus Technology
# License::   Distributes under the same terms as Ruby

require 'yaml'
require_relative 'src/Console'
require_relative 'src/Courier'
require_relative 'src/Item'
require_relative 'src/Coin'
require_relative 'src/Utility'

# Parent Class for ORIANA
class Oriana

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
		@state = :standard

		# Create the console
		# Block: All actions for input
		@console = Console.new( 30, 120, 'Oriana') do |input, out|

			# Input STATE switch
			case @state
			# Standard input
			when :standard
				case input.value

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
						name = vars.first											# snag the name
						@s.color_lists[ name ] = vars[ 1, vars.length - 1 ]			# input the rest into session hash
						out.prompt "Color list #{name} added."						# output results

					else															# quality
						vars = input.get_vars( 'create quality list' )				# gather variables
						name = vars.first											# snag the name
						@s.quality_lists[ name ] = vars[ 1, vars.length - 1 ]		# input the rest into session hash
						out.prompt "Quality list #{name} added."					# output results
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
				##### TEMPLATE CREATION
				when /^create template$/ 											# CREATE TEMPLATE
					out.prompt 'name, color list, quality list' 					# display arguments

					str = "Color Lists\n" 											# gather color list options
					@s.color_lists.each do |key, val|
						str += "#{@s.color_list_to_s( key )}\n"
					end

					str += "\nQuality Lists\n" 										# gather quality list options
					@s.quality_lists.each do |key, val|
						str += "#{@s.quality_list_to_s( key )}\n"
					end

					out.post_sub str.chop 											# Display list options
					@state = :template  											# Set unput state

				##### INVALID INPUT
				else
					out.prompt 'Command unrecognized.' 								# command unknown

				end # standard input

			# Input for template creation
			when :template

				case input.value
				when /^exit/ 														# EXIT TEMPLATE CREATION
					out.prompt 'Exited template creation.' 
					@state = :standard 												# set state back

				when /^\d+/ 														# CREATE CHILD TEMPLATE
					
					if @root_id.is_a? NilClass 										# Check to make sure parent Template was created
						prompt 'Create a parent template first.' 					# If not, break
						break
					end

					vars = input.get_vars 											# gather variables
					if vars.length < 2 												# Check for minimum variables, break if not
						out.prompt "Invalid number of variables [#{vars.length}/2]."
				 		break
				 	end

				 	parent = vars[0] 												# snag parent ID	
				 	if @s.inventory.templates[ parent ].is_a? NilClass 				# Check parent exists, if not break
				 		out.prompt "Template [#{parent} #{@s.inventory.templates.length}] does not exist."
				 		break
				 	end

				 	name = vars[1] 													# snag name or ID
				 	req = true 														# Set default for requirement
				 	colors = @s.inventory.templates[ parent ].availible_colors 		# Set default (parent) color list
				 	quals = @s.inventory.templates[ parent ].availible_qualities 	# set default (parent) quality list

				 	unless vars[2].is_a? NilClass 									# If require argument exists
				 		if vars[2] =~ /(yes|no|true|false)/ 						# Make sure valid entries exist
				 			req = true if vars[2].include? 'yes' or vars[2].include? 'true'  # set true for yes/true
				 			req = false if vars[2].include? 'no' or vars[2].include? 'false' # set false for no/false
				 		else
				 			out.prompt 'Invalid option for required.'  				# invalid requirement argument, break
				 			break
				 		end
				 	end

				 	unless vars[3].is_a? NilClass 									# If color list arugment exists
				 		if @s.color_lists[ vars[3] ].is_a? NilClass 				# Check if color list exists. If not, break
							out.prompt "#{vars[3]} is not a valid color list."
							break
						end

						# Tempaltes have colors and qualities in a hash with only one element
						# so which color list was used can be identified by the key.
						# 	name => color list array
						colors = { vars[3] => @s.color_lists[ vars[3] ] } 			# set colors to special Hash
				 	end

				 	unless vars[4].is_a? NilClass 									# If quality list arugment exits
				 		if @s.quality_lists[ vars[4] ].is_a? NilClass 				# Check if quality list exists. If not, break
							out.prompt "#{vars[4]} is not a valid quality list."
							break
						end

						quals = { vars[4] => @s.quality_lists[ vars[4] ] } 			# set qualities to special Hash
				 	end

				 	if !@s.inventory.templates[ name ].is_a? NilClass 				# Check if name is actually an ID
				 		id = name 													# snag id
				 		@s.inventory.templates[ parent ].part_map << [id, req] 		# Add template to parent part map
				 		out.post @s.inventory.template_to_s @root_id 				# Post results
				 		@console.in.insert '0', "#{parent} " 						# Insert parent ID for speed
				 		break 														# Break because we are finished
				 	end

				 	id = @s.inventory.get_new_id 									# Adding a new Tempalte, retrive new ID

				 	@s.inventory << Template.new( name, id, colors, quals ) 		# Add new template to Inventory
				 	@s.inventory.templates[ parent ].part_map << [id, req] 			# Add ID/req to parent's part map
				 	out.post @s.inventory.template_to_s @root_id 					# Post update
				 	@console.in.insert '0', "#{parent} " 							# Insert parent ID for speed

				else 																# CREATE ROOT TEMPLATE
					vars = input.get_vars 											# gather variables
					if vars.length != 3 											# check for correct number of inputs, break if not
				 		out.prompt "Invalid number of variables [#{vars.length}/3]."
				 		break
					end

					name = vars[0] 													# snag name
					colors = vars[1] 												# snag color list
					qualities = vars[2] 											# snag quality list

					if @s.color_lists[ colors ].is_a? NilClass 						# Check if color list exists, break if not
						out.prompt "#{colors} is not a valid color list."
						break

					elsif @s.quality_lists[ qualities ].is_a? NilClass 				# Check if quality list exists, break if not
						out.prompt "#{qualities} is not a valid quality list."
						break
					end

					# Tempaltes have colors and qualities in a hash with only one element
					# so which color list was used can be identified by the key.
					# 	name => color list array
					colors = { colors => @s.color_lists[ colors ] } 				# Set up special color Hash
					qualities = { qualities => @s.quality_lists[ qualities ] } 		# set up special quality Hash
					@root_id = @s.inventory.get_new_id 								# get a new ID
					# Add new Template to Inventory
				 	@s.inventory << Template.new( name, @root_id, color_hash, qual_hash )

					out.post @s.inventory.template_to_s @root_id 					# Post update
					# Post arugments
					out.prompt 'parent (id), name, required?, color list?, quality list?'
					@console.in.insert '0', "#{@root_id} " 						 	# Insert parent id for speed

				end # template options

			end # special state

		end # Console.new

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