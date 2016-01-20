# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2015 Orthus Technology
# License::   Distributes under the same terms as Ruby 

# Sandbox Credentials
# testuser_orthus_seller Cer6eru$
# testuser_orthus_buyer  Cer6eru$

require 'net/https'
require 'nokogiri'
require_relative '../utility/XML'
require_relative '../utility/Constants'

# Sends and receives HTTPS Post requests in XML to eBay
class Call



	# +token+:: User's authentication token
	# +trading_version+:: Trading API version number
	# +shopping_version+:: Shopping API version number
	attr_accessor :trading_version, :shopping_version, :token

	# Parameters:
	# +token+:: User's authentication token
	# +app_id+:: Assigned eBay App ID.
	# +cert_id+:: Assigned eBay certificate ID.
	# +production+:: Set true when using eBay's Production environment, false when using the Sandbox environment for testing
	def initialize( app_id, cert_id, production = true, token = nil )
		
		@app_id = app_id
		@cert_id = cert_id
		@production = production
		@trading_version = '921'
		@shopping_version = '517'
		@token = token

		# Configurations
		@dev_id = '48e6fd8d-6fbe-424a-bcec-85ba23ee9e7f'

		if production
			@trade_uri = URI.parse 'https://api.ebay.com/ws/api.dll'
			@shop_uri = URI.parse 'http://open.api.ebay.com/shopping?'
		else
			@trade_uri = URI.parse 'https://api.sandbox.ebay.com/ws/api.dll'
			@shop_uri = URI.parse 'http://open.api.sandbox.ebay.com/shopping?'
		end

		# Trading API, HTTPS setup
		@trade = Net::HTTP.new( @trade_uri.host, @trade_uri.port )
		@trade.use_ssl = true  
		@trade.verify_mode = OpenSSL::SSL::VERIFY_NONE # Quick fix for ruby SSL verification problem TODO

		# Shopping API, HTTP setup
		@shop = Net::HTTP.new( @shop_uri.host, @shop_uri.port )

	end # initialize

	def make_no_auth_trade_call( call, content = '' )
		
		call_body = <<-END
<?xml version="1.0" encoding="utf-8"?>
<#{call}Request xmlns="urn:ebay:apis:eBLBaseComponents">
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
			'X-EBAY-API-COMPATIBILITY-LEVEL' => @trading_version,
			'X-EBAY-API-DETAIL-LEVEL' => '0' }

		XML.new @trade.post( @trade_uri.path, call_body, header ).body

	end # make_no_auth_trade_call


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

		call_body = <<-END
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
			'X-EBAY-API-COMPATIBILITY-LEVEL' => @trading_version,
			'X-EBAY-API-DETAIL-LEVEL' => '0' }
		
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

		call_body = <<-END
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


	def upload_picture( name, path )
		
		photo = File.open( path, 'rb' ).read

		call_body = <<-END 
--MIME_boundary
Content-Disposition: form-data; name="XML Payload"
Content-Type: text/xml;charset=utf-8

<?xml version="1.0" encoding="utf-8"?>
	<UploadSiteHostedPicturesRequest xmlns="urn:ebay:apis:eBLBaseComponents">
		<PictureName>#{name}</PictureName>
	    <RequesterCredentials>
	    	<eBayAuthToken>#{@token}</eBayAuthToken>
	    </RequesterCredentials>
    </UploadSiteHostedPicturesRequest>
--MIME_boundary
Content-Disposition: form-data; name="dummy"; filename="dummy"
Content-Transfer-Encoding: binary
Content-Type: application/octet-stream

#{photo}
--MIME_boundary--

END

		header = {
			'Content-Type' => 'multipart/form-data; boundary=MIME_boundary',
			'X-EBAY-API-SITEID' => '0',
			'X-EBAY-API-CALL-NAME' => 'UploadSiteHostedPictures',
			'X-EBAY-API-APP-ID' => @app_id,
			'X-EBAY-API-REQUEST-ENCODING' => 'XML',
			'X-EBAY-API-COMPATIBILITY-LEVEL' => @trading_version }

		XML.new @trade.post( @trade_uri.path, call_body, header ).body

	end # upload_pictures

end # Call

s = Call.new( Orthus::BUYER_TOKEN, Orthus::SANDBOX_APP_ID, Orthus::SANDBOX_CERT_ID, false )
o = Call.new( Orthus::TOKEN, Orthus::PRODUCTION_APP_ID, Orthus::PRODUCTION_CERT_ID )
