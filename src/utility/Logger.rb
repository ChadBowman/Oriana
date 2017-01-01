
class Logger

	def self.write( contents )

		File.new('../saves/log.txt', 'w') unless File.exists? '../saves/log.txt'
			

		File.open('../saves/log.txt', 'a') do |f|

			f.write "===================================================\n"

			if contents.class == Array
				contents.each do |content|
					f.write content
				end

			elsif contents.class == String
				f.write contents
			end

			f.write "\n"
		end
	end

end