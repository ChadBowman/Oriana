


require_relative 'Control'
require_relative '../model/Profile'


class Start < Control

	def action
		
		if File.exist?( '../saves/init.or' )
		
			begin
				
				File.read('../saves/init.or').each_line do |line|
					if line.include? 'Last Save:'
						@console.profile = Profile.load( line.sub('Last Save: ', '') )
						@out.top @console.profile.name
					end
				end

				raise StandardError if @console.profile.nil?

			rescue Exception => e
				@out.prompt "Load Failed! #{e}"

			end
		
		else
			run_command 'load'

		end
	end

end
