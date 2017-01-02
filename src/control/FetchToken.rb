
require 'launchy'
require_relative 'Control'
require_relative '../utility/Constants'

class FetchToken < Control


	def initialize
		super( /^(fetch|get) token/ )

		@url = "https://signin.ebay.com/ws/eBayISAPI.dll?SignIn&RuName=#{Orthus::RUNAME}&SessID="
	end

	def action( input )
		clear_binds

		@out.thinking
		result = @profile.courier.get_session_id
		@out.done_thinking

		if result['Ack'] == 'Success'
			@session_id = result['SessionID']
			Launchy.open "#{@url}#{@session_id}"
			verification

		else
			@out.prompt "#{result['ShortMessage']}"
			puts result
		end
		
	end

	private
	def verification
		
		@out.center "    [F1] Retrieve token after web verification.\n    [F2] Cancel"
		@out.post_sub ''

		bind(1){ retrieve_token }
		bind(2){} #TODO return to summary

	end

	def retrieve_token

		@out.thinking
		result = @profile.courier.fetch_token( @session_id )
		@out.done_thinking

		if result['Ack'] == 'Success'
			@profile.courier.token = result['eBayAuthToken']
			@profile.ebay[:expiration] = result['HardExpirationTime']
			@profile.save
			@out.prompt 'Token retrieved. Your Ebay account is now ready for use.'

		else
			@out.prompt "#{result['ShortMessage']}"

		end
		
	end

end