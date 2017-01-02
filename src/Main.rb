# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2015 Orthus Technology
# License::   Distributes under the same terms as Ruby

require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

	require_relative 'view/Console'
	require_relative 'model/Profile'
	require_relative 'utility/Logger'
	Dir['control/*'].each{ |file| require_relative file }

	File.new('../saves/log.txt', 'w')

	dims = [0, 0]

	File.read('../saves/init.or').each_line do |line|

		if line.include? 'Dimensions'
			dims = line.sub('Dimensions: ', '').split ' '
		end
	end


	console = Console.new( 'ORIANA', Oriana::WELCOME, dims.first.to_i, dims.last.to_i )

	console.add_command SaveLoad.new
	console.add_command CreateProfile.new
	console.add_command FetchToken.new
	console.add_command ListItem.new
	console.add_command Help.new
	console.add_command Start.new

	console.start



# Known bugs
# changing title stalls program.. maybe only when using the "/" character
# errors when discogs has no image avail
# random crashes
# use warbler to make the executable .jar
# change size