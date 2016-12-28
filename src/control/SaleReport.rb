

class SaleReport

	def initialize( sold_path, active_path )

		# in sold report quanity is i=15, item id is 12, title is 14, UPC is 36
		final = Hash.new
		i = 0
		
		File.open(sold_path, "r") do |f|
			f.each_line do |line|
				if i != 0
					data = line.split(/,/)
					final[data[12]] = "#{data[36]}#{data[14]},#{data[15]}"
				end

				i = 1

			end
		end

		i = 0
		# in active report id is 0, quantity is 5, title is 13
		File.open(active_path, "r") do |f|
			f.each_line do |line|
				
				if i != 0 
					data = line.split(/,/)
				
					if !final[data[0]].nil?
						final[data[0]] = final[data[0]] + ",#{data[5]}"
					end
				end

				i = 1

			end
		end

		report = File.open('D:\Desktop\report.csv', 'w')
		report.write "UPC,Title,Sold,Listed\n"

		final.each do |k,v|
			report.write "#{v}\n"
		end

		report.close

	end

end

#SaleReport.new('D:\Desktop\sold.csv', 'D:\Desktop\active.csv')