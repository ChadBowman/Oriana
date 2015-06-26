	def update( main_pane, sub )

		inx_main_pane, inx_sub = 0, 0
		skip = false

		@map.length.times.with_index(0) do |i| 			# For every char in map
			
			if i % @characters < @boundary 				# If we're on the main_pane pane
				if skip
					@map[i] = ' '						# Write space if skip

				elsif inx_main_pane < main_pane.length			# Else if there is still something to write to main_pane
					if main_pane[ inx_main_pane ].include? "\n"
						skip = true						# If newline skip the rest of the line
						@map[i] = ' '
					else 								# Else write normally
						@map[i] = main_pane[ inx_main_pane ]
					end

					inx_main_pane += 1						# Increment main_pane index
				end

			elsif i % @characters > @boundary			# If we're on the sub pane
				
				if skip
					@map[i] = ' ' 						# Write space if skip

				elsif inx_sub < sub.length 				# Else if there is still something to write in sub
					if sub[ inx_sub ].include? "\n"
						skip = true						# If newline skip the rest of the line
						@map[i] = ' '
					else 								# Else write normally
						@map[i] = sub[ inx_sub ]
					end

					inx_sub += 1 						# Increment sub index
				end

			end # if main_pane/sub

			# Reset Skip at each new section
			skip = false if skip and i % @characters == @boundary
			skip = false if skip and i % @characters == @characters
				
			# Write divider
			@map[i] = '|' if i % @characters == @boundary
			
		end # End loop

		replace '2.0', '29.end', @map		
	end