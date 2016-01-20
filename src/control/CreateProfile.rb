

require_relative 'Control'
require_relative '../model/Profile'

class CreateProfile < Control


	def initialize
		super( /create profile/ )
	end

	def action( input )
		clear_binds

		ops = input.get_flags 'create profile'

		if ops.empty?
			@out.prompt '-n Name -e PayPal email -z ZIP Code -u Unpaid items -p Policy violations'
		else
			build_profile ops
		end
		
		@entry.set 'create profile '
	end

	def build_profile( ops )
		
		prof = Profile.new
		begin
			ops.each do |key, val|
				case key
				when :e
					if val =~ /^\w+@\w+\.\w+$/
						prof.ebay[:paypal_email] = val
					else
						raise "Invalid format for PayPal email!"
					end

				when :n
					prof.name = val

				when :z
					if val =~ /^\d\d\d\d\d(-\d\d\d\d|\d\d\d\d)?$/
						prof.ebay[:zip] = val
					else
						raise "Invalid format for ZIP!"
					end

				when :u
					if val =~ /^\d$/
						prof.ebay[:buyer_unpaid_items] = val
					else
						raise "Invalid format for number of unpaid items!"
					end

				when :p
					if val =~ /^\d$/
						prof.ebay[:buyer_policy_violations] = val
					else
						raise "Invalid format for number of policy violations!"
					end
				end
			end

			bind(1) do
				@console.profile = prof
				prof.save
				@out.top prof.name
				@out.prompt "#{prof.name} saved."
			end

			bind(2){} #TODO exit to summary

			@out.post_both( display( prof ), sub )

		rescue Exception => e
			@out.prompt e.to_s
			puts e.backtrace
			raise e
		end
	end

	def display( prof )

		if prof.courier.token.nil?
			token_status = "This application may not be authorized to use your Ebay account.\n"
			token_status << "    Please use the command 'get token' to fix this."
		else
			token_status = "ORIANA is authorized to use your Ebay account."
		end

<<-EOF
#{banner 'New Profile'}
	
	[F1] Save changes
	[F2] Cancel
	
	Name:            #{prof.name}
	PayPal Email:    #{prof.ebay[:paypal_email]}
	ZIP:             #{prof.ebay[:zip]}

	Ebay Details
	Block buyers with #{prof.ebay[:buyer_unpaid_items]} unpaid items.
	Block buyers with #{prof.ebay[:buyer_policy_violations]} policy violations.

	#{token_status}
EOF
	end

	def sub
<<-EOF
	--- Options ---
  -n Name
  -e PayPal Email
  -z ZIP 
  -u Unpaid Items
  -p Policy Violations
EOF
	end

end