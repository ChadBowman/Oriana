
require_relative 'Control'
require_relative '../model/Profile'

class SaveLoad < Control

	def initialize
		super( /(save|load)/ )
	end

	def action( input )
		clear_binds

		save if input.value == 'save'
		load if input.value == 'load'

	end

	def save
		
		begin
			@profile.save
			@out.prompt "#{@profile.name} saved."

		rescue Exception => e
			@out.prompt "Save failed!"
			
		end

	end

	def load
		begin
			# Grab all save files
			files = Dir['../saves/*.yml']
			profs = Array.new

			# Load each Profile to array
			files.each do |file|
				profs << Profile.load( file.gsub( /(^.*\/|\.yml)/, '' ) )
			end

			# No profiles
			if profs.empty?
				@out.prompt "There are no profiles saved! Create one with 'create profile'."

			# Only 1 profile available
			elsif profs.size == 1
				
				# Load in profile
				@console.profile = profs.first
				@out.top "#{profs.first.name}"

			# More than 1 profile
			else
				str = "  Load which profile?\n"
				profs.each_with_index do |p, i|

					str << "\n    [F#{i+1}] #{p.name}"

					#TODO what if more than 12 files?

					# Bind F-keys to options
					bind( i+1 ) do 
						@console.profile = profs[i]
						@out.prompt "#{profs[i].name} loaded."
						@out.top "#{profs[i].name}"
					end

				end

				# Prompt user for response 
				@out.center str

			end

		# Handle file exceptions
		rescue Exception => e
			@out.prompt "Load failed!"
			puts e

		end

	end # load

end # LoadSave