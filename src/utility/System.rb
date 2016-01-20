



class System

	def self.memory


		info = `systeminfo`
		total = Integer info[/Total.*\n/][/(\d|,)+/].gsub(',', '')
		avail = Integer info[/Available.*\n/][/(\d|,)+/].gsub(',', '')
		used = total - avail

		"(%.2f%%) of %.0fGB" % [used.to_f / total.to_f * 100.0, total.to_f / 1000]
		
	end
end