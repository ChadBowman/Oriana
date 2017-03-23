# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2015 Orthus Technology
# License::   Distributes under the same terms as Ruby
require 'openssl'

require_relative 'view/Console'
require_relative 'model/Profile'
require_relative 'utility/Logger'
require_relative 'control/Control'
require_relative 'control/SaveLoad'
require_relative 'control/CreateProfile'
require_relative 'control/FetchToken'
require_relative 'control/ListItem'
require_relative 'control/Help'
require_relative 'control/Start'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

dir = Dir.pwd[/.*Oriana/]
init_file_path = "#{dir}/src/saves/init.or"

# handle initialization file
if File.exist? init_file_path
    File.read(init_file_path).each_line do |line|
        dims = line.sub('Dimensions: ', '').split(' ') if line.include? 'Dimensions'
    end
else
    File.open(init_file_path, 'w') do |file|
        file.write 'Dimensions: 0 0'
    end
    dims = [0, 0]
end

console = Console.new( 'ORIANA', Oriana::WELCOME, dims.first.to_i, dims.last.to_i )

console.add_command SaveLoad.new
console.add_command CreateProfile.new
console.add_command FetchToken.new
console.add_command ListItem.new
console.add_command Help.new
console.add_command Start.new

# delete temp files
begin
    t = Thread.new do
        Dir.foreach("#{dir}/temp/") do |f|
            fn = File.join("#{dir}/temp/", f)
            File.delete(fn) if (f != '.' && f != '..')
        end
    end
t.join

rescue Exception => e
    puts e
end

console.start

# Known bugs
# changing title stalls program.. maybe only when using the "/" character
# errors when discogs has no image avail
# change size
