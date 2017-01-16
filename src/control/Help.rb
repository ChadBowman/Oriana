

class Help < Control


	def initialize
		super(/^help ?/)
	end

	def action( input )
		clear_binds
		case input.value.sub(/help ?/, '')
		when ''
			@out.post <<-EOF
	Command                          |  Description
-----------------------------------------------------------------------------
create profile (flags)               |  Create new Ebay profile.
[fetch|get] token                    |  Authenticate Ebay profile for use.
list (flags) [upc|"search text"]     |  List vinyl or CD.
help (create profile|get token|list) |  Detailed documentation on command.
save                                 |  Save current profile settings.
load                                 |  Load different profile.
-----------------------------------------------------------------------------

Flags are options which are designated with a dash e.g. -p. Not all 
	flags have to be used in the same command or in any particular order.

() optional, [] required, | logical 'or'

Email Chad for futher questions or bug reports: chad.bowman0@gmail.com.
EOF
		when /(fetch|get) token/
			@out.post <<-EOF
    Fetch Token
-----------------------------------------------------------------------------
Use to authenticate a new Ebay account. You will be redirected to Ebay's site
to enter your password. This opperation only needs to be completed once.
EOF
		when /create profile/

			@out.post <<-EOF
    Create Profile
-----------------------------------------------------------------------------
Flags:
-e [something@something.com]: Paypal email.
-n [anything you want]: Profile name.
-z [90201]:  ZIP code from shipping origin (59715 for Bozeman).
-u [0-5]:  Limit customers to how many unpaid item strikes they have.
-p [0-5]:  Limit customers to how many policy violation stikes they have.

Example:
create profile -e mypaypal@email.com -n Cactus Records -u 3

() optional, [] required, | logical 'or'
EOF

		when /list/
			@out.post <<-EOF
    List
-----------------------------------------------------------------------------
Flags:
-p [12|12.34]: Fixed price or auction starting price.
-q [1-100]: Item quantity (only useable in fixed price listings).
-c [new|used]: Item condition.
-t (A new title): Listing title. Leaving no option will return the old title
	to the entry bar for easy modification. (80 character limit)
-w [1-100]: Item weight in pounds.
-d [a description]: Detailed item description.
-v [NM description]: Vinyl/CD condition. Must lead with a code like M or VG+,
	mint or very good plus respectively then followed by any text.
-j [M description]: Vinyl jacket/CD case condition. Same rules as -v.
-l [fixed|auction]: List as an auction or fixed price.
-upc [list ]: Set UPC code of item.
-i (path_to_image(, another_path)*): Images to upload. File paths can be separated
	by commas. Alternatively, you can leave the option blank and select files
	via a dialog window. Try it! 

Examples:
list -p 45.65 -v NM Looks great! -d Limited edition -v NM- Great! 016861766313
list -w 3 "stone sour house of gold and bones 1"
list 016861766313 -t "new title" -i

() optional, [] required, | logical 'or', * repeatable
EOF
		end

	end

end # Help