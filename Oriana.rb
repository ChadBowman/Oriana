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


	def initialize

		@profiles = {
			orthus: Profile.new( true, 'AgAAAA**AQAAAA**aAAAAA**AaJ4VQ**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6AFkIOnD5WKoAqdj6x9nY+seQ**W8oCAA**AAMAAA**ZPA6X9PG7HZ1yZZFO94/Ntq2ks/p7GS6Ke3yf80Uql7ow77sMKOZkH0vIP275Ho36JKbyu5brwSEzENty/NZFgsVo6Dbik0c7VFAfr8KobRiUVwD8T+0e5rsSz/7wsAO4gX6V0O1YYLX95OwZx0dsMA7OCpuXh32HPhDrzWnjEfXrpFiSDKQ5c287U6aeSNRBziInqqWpvdj9JxeeIUs61rx5exQqKpAKCdNoElnvMfC2SMbWkV83xUaH5xqnYVe2VUNuQZvFGkh/KZIWLsssC/Dexrcg31iM+aidVIj83A7pfIWNkgM0C5ZPiPjEq//YWM0gS6NIoFYgyvGxpq2mw+KrsIxxLdMxlTx4YWaVDfKz7n8VUm0ozKioXGaQrbwPodHY4a/Uw6Cbv77ChTho7hzRc9bNqznNkVrv4tKthNbDAT1HN7TVL0M9DoahywlnzPPQj5kyuKCUC+D9bADjEtKTLTk/9TOn+OwTs1M6aVxJajo22r7CpxnQgQQL3OyViPVKAzukDUyKAQ9RznV5I9Lu+9SVBv7Xwb2uRS69qipDy/jOm092kOhZjl8GfD+eqlXj66WwkPbHlz/wQFxhow7Td5Lmn24qCTQId6192W/0AlduIk7QlPxgkLdRVn5Lq/REXvFiyM37OIpA+UL08kPcTALd6hXMWAXqWn10FjCe12mhJi1ibWp6sWmx+xk5OQEfilmArQFZsjCBje2KReIIrNGPJcJnpT+VsUljcHoRKTr6rH7KOi9imjxqvMo' ),
			buyer:  Profile.new( false, 'AgAAAA**AQAAAA**aAAAAA**kD8lVQ**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4GhDZWGpQ2dj6x9nY+seQ**/mMDAA**AAMAAA**2GScRUabHVT/RRkzlq4kTR6OJsKE/n2kiL9DthmMgbfszMKfzxIWQYj4PQ19f1UFdSpQ/a+4zA1ekphWVfQEqG1iFqFj+kbKnO84EjA2lXmYq9IWxyTyxedd96VQhI4hfsc0ot3T6pAGjof/wBPiaetTAZdySPbhni7nUe9goy28YHL+wSC8Rbce9vO2vlnuscE0PEFlDHZ6uCr9uijGprAlmAHgFqYn5mex7llOJG59EVswsFcVKDsVihgQJHqUKXqrslsA/9KbQrLLo5I97c2ePelaXKKrZXyuj3KW6rit2fRVfUbzxG1ADse0c1qQtQrDZV3ZNuxzQJh4d+xd2X7HqqsacU3ruxQoMfss9ea09AbW/UUhbS/OBs8G/Nez8C5j0BDHQDNXKym0MS9lH+2Us0JDwxTG1EvYXquj9SKUkOoFu+fWSi2gFtBJn+I9Unz8e67nSA6lYkJ66STgV4aL3XT7gVIQZmql0I6qjPtcvZSi3ym0bBNwM5hGKYk6fUyEKhxw/AN+RvRhRaj1GPyMtEM4NIKBpOiTQ5q1/a8xxoiPd4Z0qNRM0y9Bdlv3YqzphRJ0FZYL6q6E7S0mOVJuEQOXLofD/PjFaHY3eQTvNJC/3FoVFtXNLSzUcfIhKzT9sl7OIPTqSKQ1LYOe4ERocPtML/ag1nIs8ETCefCL82DyMsxRroDFIgl8I4SsllYBg/vlmLvPiMVU6XPqkHw5rUuFD/ARHc8XZyx7q0yloyO+7ejXbQBm290ykKQT' ),
			seller: Profile.new( false, 'AgAAAA**AQAAAA**aAAAAA**gzqAVQ**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4GhDZiCoA6dj6x9nY+seQ**/mMDAA**AAMAAA**g8zWPzS6q0dMf0j0kt3VtE5wRbh0A6yhTP/xmS4PvGLZJpvgaTdteKRoS/c1aELoJXg+Z+83GW32PLCvS/WDEfu3gSs+cVR48cTw8ipS0J243zM1pbahGMP7IdIj7D5+auoDptcrqWCTBZbiGE5Efvb5MIiOYpmb97sI4WCelRMTGoachyE5U6sSj9nf79450iC8LNiaFAv6tC1Dk7UHzFTnoo10uj/8yQb8iu79k9Yki2Zhj1aKqF2eD+gjlkJqQUEhv5aifXe4mkFiz77xlCU82aOTne0nNjO1RNalZUCp3jylxL3blL6HyEm7SMy3IhQYt448DfoRhdejyBWU3fXNBhlTXiPxU4AJBan2lSJ5OPONrOGFop+1i9jPlGZxKPDhrkF3bbQ3/7iC7lUXGuucSaijs0Ud/OxEA9y+6VkabDtdhwk6M3YETscAf9797BZw5YzlEvEdmmQV3xDmC9gzEl/s8GkH0Yb4c2u0DPd+uf4DdqHY9fjuajElc2xjCWfWnCvWRHRNxKvJ4x6hwGWdTouVBlwHP+sPT0lnozu8B+QRWxAli6kECkYkErQyPk7hQvPOiV19LF9ur/gfFKYRnH0zHRsuvgN0uKT762yH6vyFaob8ePgbZACRwk+ioviS1mPlgriainvyk3Xwvu/aMXFG/scG7GXNOzfXUl2NQsR7z4Hw66jvB8Z4tGgspKF5zYx/kQ9fCTM56hou2MRR6WvrMfeOhzoOPF9mgudeSafQaw+PthKgEsCkpC87' )
		}


		Thread.new do
			str = String.new

			IO.foreach('saves/session.or') do |line|
				str += line
			end

			@s = YAML.load str
			courier = Courier.new @profiles[ @s.profile ].token, @profiles[ @s.profile ].production
		end

		@state = :standard

		@console = Console.new( 30, 120, 'Oriana') do |input, out|

			case @state
			when :standard

				case input.value

				##### PROFILE
				when /^set profile/

					x = input.get_vars( 'set profile' ).to_sym
					
					if @profiles[x].is_a? NilClass
						out.prompt "Profile #{x} does not exist."
						
					else
						@s.profile = x
						out.prompt "Profile set to: #{x}."
					end

				when /^show profile/
					out.prompt "Profile: #{@s.profile}"

				##### COLOR/QUALITY
				when /^create (color|quality) list/
					if input.value.include? 'color'
						vars = input.get_vars( 'create color list' )

						name = vars.first
						@s.color_lists[ name ] = vars[ 1, vars.length - 1 ]

						out.prompt "Color list #{name} added."
					else
						vars = input.get_vars( 'create quality list' )

						name = vars.first
						@s.quality_lists[ name ] = vars[ 1, vars.length - 1 ]

						out.prompt "Quality list #{name} added."
					end

				when /^add colors? to/
					vars = input.get_vars( 'add color to' )
					name = vars.first
					vars = vars[ 1, vars.length - 1 ]

					vars.each do |color|
						@s.color_lists[ name ] << color
					end

					@s.inventory.update_color( name, @s.color_lists[ name ] )

					out.prompt "Colors added to #{name}."

				when /^delete (color|quality) list/
					if input.value.include? 'color'
						var = input.get_vars( 'delete color list' )
						@s.color_lists.delete var
						@s.inventory.update_color( name, nil )

					else
						var = input.get_vars( 'delete quality list' )
						@s.quality_lists.delete var
					end

					out.prompt "#{var} deleted."

				when /^show (color|quality) lists/
					str = String.new

					if input.value.include? 'color'
						@s.color_lists.each do |key, value|
							str += "#{@s.color_list_to_s( key )}\n"
						end

					else
						@s.quality_lists.each do |key, val|
							str += "#{@s.quality_list_to_s( key )}\n"
						end
					end

					out.post str.chop 

				##### TEMPLATE CREATION
				when /^create template$/
					out.prompt 'name, color list, quality list'

					str = "Color Lists\n"
					@s.color_lists.each do |key, val|
						str += "#{@s.color_list_to_s( key )}\n"
					end

					str += "\nQuality Lists\n"
					@s.quality_lists.each do |key, val|
						str += "#{@s.quality_list_to_s( key )}\n"
					end

					out.post_sub str.chop	

					@state = :template1


				##### INVALID INPUT
				else
					out.prompt 'Command unrecognized.'

				end # standard input

			when :template1

				case input.value

				when /^exit/
					out.prompt 'Exited template creation.'
					@state = :standard

				when /^\d+/ 
					# parent, name, required?, color list, quality list
					vars = input.get_vars

					if vars.length < 2
						out.prompt "Invalid number of variables [#{vars.length}/2]."
				 		break
				 	end

				 	parent = vars[0]
				 	if @s.inventory.templates[ parent ].is_a? NilClass
				 		out.prompt "Template [#{parent} #{@s.inventory.templates.length}] does not exist."
				 		break
				 	end


				 	name = vars[1]
				 	req = true
				 	colors = @s.inventory.templates[ parent ].availible_colors
				 	quals = @s.inventory.templates[ parent ].availible_qualities

				 	unless vars[2].is_a? NilClass
				 		if vars[2] =~ /(yes|no|true|false)/
				 			req = true if vars[2].include? 'yes' or vars[2].include? 'true'
				 			req = false if vars[2].include? 'no' or vars[2].include? 'false'
				 		else
				 			out.prompt 'Invalid option for required.'
				 			break
				 		end
				 	end

				 	unless vars[3].is_a? NilClass
				 		if @s.color_lists[ vars[3] ].is_a? NilClass
							out.prompt "#{vars[3]} is not a valid color list."
							break
						end

						colors = { vars[3] => @s.color_lists[ vars[3] ] }
				 	end

				 	unless vars[4].is_a? NilClass
				 		if @s.quality_lists[ vars[4] ].is_a? NilClass
							out.prompt "#{vars[4]} is not a valid quality list."
							break
						end

						quals = { vars[4] => @s.quality_lists[ vars[4] ] }
				 	end

				 	id = @s.inventory.get_new_id
				 	puts "ID: #{id}"
				 	@s.inventory << Template.new( name, id, colors, quals )
				 	@s.inventory.templates[ parent ].part_map << [id, req]

				 	out.post @s.inventory.template_to_s '1'

				else
					# take in name, colors, qualities
					vars = input.get_vars

				 	# Check for correct number of inputs
					if vars.length != 3
				 		out.prompt "Invalid number of variables [#{vars.length}/3]."
				 		break
					end

					name = vars[0]
					colors = vars[1]
					qualities = vars[2]

					 # Check list selections
					if @s.color_lists[ colors ].is_a? NilClass
						out.prompt "#{colors} is not a valid color list."
						break

					elsif @s.quality_lists[ qualities ].is_a? NilClass
						out.prompt "#{qualities} is not a valid quality list."
						break
					end

					color_hash = { colors => @s.color_lists[ colors ] }
					qual_hash = { qualities => @s.quality_lists[ qualities ] }

					id = @s.inventory.get_new_id
					@root_id = id
				 	@s.inventory << Template.new( name, id, color_hash, qual_hash )

					out.post @s.inventory.template_to_s id 
					out.prompt 'parent (id), name, required?, color list?, quality list?'
				end

			end # special state

			@start = false

		end # Console.new

		@console.root.bind('Control-s') do
			File.write 'saves/session.or', @s.to_yaml
			@console.out.prompt 'Saved'
		end

		#courier = Courier.new( @profiles[x].token, @profiles[x].production )
	
		@console.out.insert 'end', C::WELCOME
		@console.start

	end # initialize

	
end


Oriana.new