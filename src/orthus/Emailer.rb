require 'net/smtp'
require_relative 'Utility'

SECONDS_IN_DAY = 86400
CUTOFF_TIME = 14

class Emailer

	attr_accessor :name, :to, :from

	def initialize( name, to, from = 'chad@orthus.net' )
		@name, @to, @from = name, to, from		
	end

	def completion_notice( tracking )

		date = next_ship_date().strftime("%A, %B %d")

content = <<END
<p style="color:#696969;">Dear #{@name},<br><br>The repair was a success and will ship #{date}.
Your USPS tracking number is <a style="color:#A37A00; text-decoration:none;" href="
https://tools.usps.com/go/TrackConfirmAction.action?tRef=fullpage&tLc=1&tLabels=#{tracking}">
#{tracking}</a>.<br><br>If you used Ebay, save money on your next repair by using our website at <a href='http://www.orthus.net'
style='color:#A37A00; text-decoration:none;'>orthus.net</a>.<br><br>We really appreciate your business
and seek your 5-star positive feedback. If there are any problems or concerns please contact us 
so we can make it right. Thanks again and have a great day!<br>
<br>Sincerely,<br><br>Chad Bowman<br>Orthus Technology</p><br><br><a href='http://www.orthus.net'>
<center><img src="http://orthus.net/images/Signature.jpg"></center></a>
END
		send( 'Repair(s) Completed', content )
	end

	def aquisition_notice
content = <<END
<p style="color:#696969;">Dear #{@name},<br><br>Your
console has arrived and a final diagnosis has been completed. Please
look out for an itemized invoice via Paypal within the next hour. Information
regarding the diagnosis and reasons for repair can be found in the note section 
of the invoice. As soon as payment has been received, the repair(s) will be conducted 
and a confirmation email will be sent with your tracking number. Feel free to 
respond to this email to ask any questions or voice any concerns.<br><br>Thank 
you for your support,<br><br>Chad Bowman<br>Orthus Technology</p><br><br>
<a href="http://www.orthus.net"><center><img src="http://orthus.net/images/
Signature.jpg"></center></a>
END
		send( 'Console(s) Received (Action Needed)', content)
	end

	def purchase_confirmation
content = <<END
<p style="color:#696969;">Dear #{@name},<br><br>Thank you for purchasing one of our
Nintendo DS/3DS repair services. At your earliest convenience, please send your console to:<br>
<br>Orthus Repairs<br>1104 S Montana Ave #C8<br>Bozeman, MT 59715<br><br>Please be sure
to have tracking with your shipping service to ensure your console does not
get lost in the post. We recommend saving some time and money by <a style="color:#A37A00;
text-decoration:none;" href="https://cns.usps.com/go">purchasing flat rate postage with
USPS online</a>. Once received and diagnosed, another email will be sent here.
Feel free to respond to this email to ask any questions.<br><br>Thank you,<br><br>
Chad Bowman<br>Orthus Technology</p><br><br><a href="http://www.orthus.net"><center>
<img src="http://orthus.net/images/Signature.jpg"></center></a>
END
		send( 'Console Repair Confirmation', content )
	end

	# Sends HTML formatted email @to, @from an @orthus.net email.
	# with _subject_ and _content_.
	def send( subject, content )

		raise ArgumentError, 'Invalid from address. (use something@orthus.net)' unless @from =~ /@orthus.net/

message = <<END
From: Chad Bowman <#{@from}>
To: #{@name} <#{@to}>
MIME-Version: 1.0
Content-type: text/html
Subject: #{subject}

#{content}
END

	smtp = Net::SMTP.start('gator3257.hostgator.com', 465, 'localhost', 'chad@orthus.net', '0rthu$Tech', :login)
	smtp.send_message( message, @from, @to )
	smtp.finish

	puts "Email sent to #{@to}."
	end

	private
	def next_ship_date( date = Time.new )
																						# Today is
		if C::HOLIDAYS.include? date.to_s[/\d{4}\-\d\d\-\d\d/] or					# Holiday?
			(Time.new.day == date.day and date.hour > CUTOFF_TIME) or date.wday == 0	# After cut-off or Sunday?
				next_ship_date( date + SECONDS_IN_DAY ) # Check tomorrow
		else
			return date # Safe to ship
		end

	end
end


#Emailer.new('Derrick Chaitar', 'derrickchaitar@gmail.com').completion_notice('9405503699300137406859')
Emailer.new('Adam Stevens', 'chad.bowman0@gmail.com').completion_notice('9405509699937122482103')

