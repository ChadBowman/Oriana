# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2015 Orthus Technology
# License::   Distributes under the same terms as Ruby

require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE


require_relative 'utility/Constants'
require_relative 'view/Console'
require_relative 'model/Profile'
Dir['control/*'].each{ |file| require_relative file }

console = Console.new( 'ORIANA', Oriana::WELCOME, 28, 120 )


console.add_command SaveLoad.new
console.add_command CreateProfile.new
console.add_command FetchToken.new
console.add_command ListItem.new
console.add_command Start.new



console.start

# To work on: Calculated shipping doesnt work. 
# Warn when images are less than 500px wide
# upload images
# add record label
# attribute list showing duplicates
# record and sleeve gradings
# speed
# country of manufact
# Store categories

=begin
081227949501 hangs on search
=end