

require 'yaml'

require_relative '../discogs/Discogs'
require_relative '../ebay/Courier'
require_relative '../ebay/Call'
require_relative '../utility/Constants'

class Profile

	@@number = 0

	attr_accessor :name, :ebay, :discogs, :courier, :defaults

	def initialize

		@ebay = Hash.new
		@ebay[:buyer_unpaid_items] = '3'
		@ebay[:buyer_policy_violations] = '3'

		@discogs = Discog.new

		@courier = Courier.new( Call.new(
			Orthus::PRODUCTION_APP_ID,
			Orthus::PRODUCTION_CERT_ID ))


		@@number += 1

		@name = "Profile #{@@number}"

		@defaults = {w: 0, h: 0}

	end

	def self.load( name )
		
		prof = YAML.load_file "../saves/#{name}.yml"

		prof.courier = Courier.new( Call.new(
		 	Orthus::PRODUCTION_APP_ID,
		 	Orthus::PRODUCTION_CERT_ID,
		 	true, prof.courier.token ))

		prof
	end

	def save
		defaults[:h] = 34
		defaults[:w] = 147
		name = @name.gsub(' ', '')
		
		File.open("../saves/#{name}.yml", 'w+') do |file|
			file.write self.to_yaml
		end

		File.open("../saves/init.or", 'w+') do |file|
			file.write "Last Save: #{name}\n"
			file.write "Dimensions: #{defaults[:w]} #{defaults[:h]}"
		end

	end

	def ready?
		if @ebay[:paypal_email].nil? or @ebay[:zip].nil? or @courier.token.nil?
			false
		else
			true
		end
	end

end