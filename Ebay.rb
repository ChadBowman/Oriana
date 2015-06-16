# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2015 Orthus Technology
# License::   Distributes under the same terms as Ruby 

require 'net/https'
require_relative 'XML'

# Error to be used when sending a call to eBay fails
class CallError < StandardError
end

# Sends and receives HTTPS Post requests in XML to eBay
class Call

	# +token+:: User's authentication token
	attr_writer :token

	# +trading_version+:: Trading API version number
	# +shopping_version+:: Shopping API version number
	attr_accessor :trading_version, :shopping_version

	# Parameters:
	# +production+:: Set true when using eBay's Production environment, false when using the Sandbox environment for testing
	# +token+:: User's authentication token
	def initialize( token, production = true )
		self.token = token
		@production = production
		@trading_version = '921'
		@shopping_version = '517'

		# Configurations
		@dev_id = '48e6fd8d-6fbe-424a-bcec-85ba23ee9e7f'

		if production
			@trade_uri = URI.parse 'https://api.ebay.com/ws/api.dll'
			@shop_uri = URI.parse 'http://open.api.ebay.com/shopping?'
			@app_id = 'OrthusTe-b249-4e73-a34e-763549ce8b1e'
			@cert_id = '3f3a6c4d-1b02-40dc-8b8c-295cc7043dd3'
		else
			@trade_uri = URI.parse 'https://api.sandbox.ebay.com/ws/api.dll'
			@shop_uri = URI.parse 'http://open.api.sandbox.ebay.com/shopping?'
			@app_id = 'OrthusTe-96ce-48db-a0e4-82dbbcb37804'
			@cert_id = 'e6547f74-f0f3-473f-9b73-03814cd78dc6'
		end

		# Trading API, HTTPS setup
		@trade = Net::HTTP.new( @trade_uri.host, @trade_uri.port )
		@trade.use_ssl = true  
		@trade.verify_mode = OpenSSL::SSL::VERIFY_NONE # Quick fix for ruby SSL verification problem TODO

		# Shopping API, HTTP setup
		@shop = Net::HTTP.new( @shop_uri.host, @shop_uri.port )

	end # initialize


	# Makes a call to eBay's Trading API. Requires a working token to work.
	#
	# Parameters:
	# +call+:: Command from eBay's Trading API
	# +content+:: Formatted content needed for the particular call command
	# 
	# Returns:
	# 1. +Boolean+ true if the call was successful, false if warnings present
	# 2. +XML+ Response body
	def make_trade_call( call, content = '' )

		call_body = <<END
<?xml version="1.0" encoding="utf-8"?>
<#{call}Request xmlns="urn:ebay:apis:eBLBaseComponents">
	<RequesterCredentials>
		<eBayAuthToken>#{@token}</eBayAuthToken>
	</RequesterCredentials>
#{content}
</#{call}Request>
END

		header = {
			'Content-Type' => 'text/xml',
			'X-EBAY-API-SITEID' => '0',
			'X-EBAY-API-CALL-NAME' => call,
			'X-EBAY-API-CERT-NAME' => @cert_id,
			'X-EBAY-API-APP-NAME' => @app_id,
			'X-EBAY-API-DEV-NAME' => @dev_id,
			'X-EBAY-API-COMPATIBILITY-LEVEL' => @trading_version }

		# Post request and get response
		XML.new @trade.post( @trade_uri.path, call_body, header ).body

	end # make_trade_call

	# Makes a call to eBay's Shopping API. No token is needed here.
	# 
	# Parameters:
	# +call+:: Command from eBay's Shopping API
	# +content+:: Formatted content needed for the particular call command
	# 
	# Returns:
	# +XML+ Response body
	def make_shop_call( call, content = '' )

		call_body = <<END
<?xml version="1.0" encoding="utf-8"?>
<#{call}Request xmlns="urn:ebay:apis:eBLBaseComponents">
#{content}
</#{call}Request>
END

		header = {
			'Content-Type' => 'text/xml',
			'X-EBAY-API-SITEID' => '0',
			'X-EBAY-API-CALL-NAME' => call,
			'X-EBAY-API-APP-ID' => @app_id,
			'X-EBAY-API-REQUEST-ENCODING' => 'XML',
			'X-EBAY-API-VERSION' => @shopping_version }

		# Post request, return body
		XML.new @shop.post( @shop_uri.path, call_body, header ).body

	end # make_shop_call

end # Call



# Sends and receives HTTPS calls to eBay with Call
class Courier

	def initialize( token, production = true )
		@call = Call.new( token, production )
	end

	def token=( token )
		@call.token = token		
	end

	def ebay_time
		@call.make_shop_call 'GeteBayTime'
	end

	def find_products( keywords )

		if keywords.is_a? Fixnum
			keywords = "<ProductID type='Reference'>#{keywords}</ProductID>"
		else
			keywords = "<QueryKeywords>#{keywords}</QueryKeywords>"
		end

		puts keywords

		call = 'FindProducts'
		body = <<END
<AvailableItemsOnly>false</AvailableItemsOnly>
<HideDuplicateItems>true</HideDuplicateItems>
<MaxEntries>20</MaxEntries>
#{keywords}
END
		@call.make_shop_call call, body
	end

end # Courier



orthus_tech_token = 'AgAAAA**AQAAAA**aAAAAA**AaJ4VQ**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6AFkIOnD5WKoAqdj6x9nY+seQ**W8oCAA**AAMAAA**ZPA6X9PG7HZ1yZZFO94/Ntq2ks/p7GS6Ke3yf80Uql7ow77sMKOZkH0vIP275Ho36JKbyu5brwSEzENty/NZFgsVo6Dbik0c7VFAfr8KobRiUVwD8T+0e5rsSz/7wsAO4gX6V0O1YYLX95OwZx0dsMA7OCpuXh32HPhDrzWnjEfXrpFiSDKQ5c287U6aeSNRBziInqqWpvdj9JxeeIUs61rx5exQqKpAKCdNoElnvMfC2SMbWkV83xUaH5xqnYVe2VUNuQZvFGkh/KZIWLsssC/Dexrcg31iM+aidVIj83A7pfIWNkgM0C5ZPiPjEq//YWM0gS6NIoFYgyvGxpq2mw+KrsIxxLdMxlTx4YWaVDfKz7n8VUm0ozKioXGaQrbwPodHY4a/Uw6Cbv77ChTho7hzRc9bNqznNkVrv4tKthNbDAT1HN7TVL0M9DoahywlnzPPQj5kyuKCUC+D9bADjEtKTLTk/9TOn+OwTs1M6aVxJajo22r7CpxnQgQQL3OyViPVKAzukDUyKAQ9RznV5I9Lu+9SVBv7Xwb2uRS69qipDy/jOm092kOhZjl8GfD+eqlXj66WwkPbHlz/wQFxhow7Td5Lmn24qCTQId6192W/0AlduIk7QlPxgkLdRVn5Lq/REXvFiyM37OIpA+UL08kPcTALd6hXMWAXqWn10FjCe12mhJi1ibWp6sWmx+xk5OQEfilmArQFZsjCBje2KReIIrNGPJcJnpT+VsUljcHoRKTr6rH7KOi9imjxqvMo'
token = 'AgAAAA**AQAAAA**aAAAAA**kD8lVQ**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4GhDZWGpQ2dj6x9nY+seQ**/mMDAA**AAMAAA**2GScRUabHVT/RRkzlq4kTR6OJsKE/n2kiL9DthmMgbfszMKfzxIWQYj4PQ19f1UFdSpQ/a+4zA1ekphWVfQEqG1iFqFj+kbKnO84EjA2lXmYq9IWxyTyxedd96VQhI4hfsc0ot3T6pAGjof/wBPiaetTAZdySPbhni7nUe9goy28YHL+wSC8Rbce9vO2vlnuscE0PEFlDHZ6uCr9uijGprAlmAHgFqYn5mex7llOJG59EVswsFcVKDsVihgQJHqUKXqrslsA/9KbQrLLo5I97c2ePelaXKKrZXyuj3KW6rit2fRVfUbzxG1ADse0c1qQtQrDZV3ZNuxzQJh4d+xd2X7HqqsacU3ruxQoMfss9ea09AbW/UUhbS/OBs8G/Nez8C5j0BDHQDNXKym0MS9lH+2Us0JDwxTG1EvYXquj9SKUkOoFu+fWSi2gFtBJn+I9Unz8e67nSA6lYkJ66STgV4aL3XT7gVIQZmql0I6qjPtcvZSi3ym0bBNwM5hGKYk6fUyEKhxw/AN+RvRhRaj1GPyMtEM4NIKBpOiTQ5q1/a8xxoiPd4Z0qNRM0y9Bdlv3YqzphRJ0FZYL6q6E7S0mOVJuEQOXLofD/PjFaHY3eQTvNJC/3FoVFtXNLSzUcfIhKzT9sl7OIPTqSKQ1LYOe4ERocPtML/ag1nIs8ETCefCL82DyMsxRroDFIgl8I4SsllYBg/vlmLvPiMVU6XPqkHw5rUuFD/ARHc8XZyx7q0yloyO+7ejXbQBm290ykKQT'

c = Courier.new token, false
puts c.ebay_time