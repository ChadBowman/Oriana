module C

	VERSION = '1.0'

	WELCOME = <<-END 
		\n\n\n\n\n\n\n\n\n\n
				   Orthus Technology
				   _____   ______ _____ _______ __   _ _______
				  |     | |_____/   |   |_____| | \\  | |_____|
				  |_____| |    \\_ __|__ |     | |  \\_| |     |
					
    	 		   	        			         Version: #{VERSION}
    	\n\n\n\n\n\n\n\n\n\n\n\n\n
		END

	PROFILES = {
		orthus: Profile.new( true, 'AgAAAA**AQAAAA**aAAAAA**AaJ4VQ**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6AFkIOnD5WKoAqdj6x9nY+seQ**W8oCAA**AAMAAA**ZPA6X9PG7HZ1yZZFO94/Ntq2ks/p7GS6Ke3yf80Uql7ow77sMKOZkH0vIP275Ho36JKbyu5brwSEzENty/NZFgsVo6Dbik0c7VFAfr8KobRiUVwD8T+0e5rsSz/7wsAO4gX6V0O1YYLX95OwZx0dsMA7OCpuXh32HPhDrzWnjEfXrpFiSDKQ5c287U6aeSNRBziInqqWpvdj9JxeeIUs61rx5exQqKpAKCdNoElnvMfC2SMbWkV83xUaH5xqnYVe2VUNuQZvFGkh/KZIWLsssC/Dexrcg31iM+aidVIj83A7pfIWNkgM0C5ZPiPjEq//YWM0gS6NIoFYgyvGxpq2mw+KrsIxxLdMxlTx4YWaVDfKz7n8VUm0ozKioXGaQrbwPodHY4a/Uw6Cbv77ChTho7hzRc9bNqznNkVrv4tKthNbDAT1HN7TVL0M9DoahywlnzPPQj5kyuKCUC+D9bADjEtKTLTk/9TOn+OwTs1M6aVxJajo22r7CpxnQgQQL3OyViPVKAzukDUyKAQ9RznV5I9Lu+9SVBv7Xwb2uRS69qipDy/jOm092kOhZjl8GfD+eqlXj66WwkPbHlz/wQFxhow7Td5Lmn24qCTQId6192W/0AlduIk7QlPxgkLdRVn5Lq/REXvFiyM37OIpA+UL08kPcTALd6hXMWAXqWn10FjCe12mhJi1ibWp6sWmx+xk5OQEfilmArQFZsjCBje2KReIIrNGPJcJnpT+VsUljcHoRKTr6rH7KOi9imjxqvMo' ),
		buyer:  Profile.new( false, 'AgAAAA**AQAAAA**aAAAAA**kD8lVQ**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4GhDZWGpQ2dj6x9nY+seQ**/mMDAA**AAMAAA**2GScRUabHVT/RRkzlq4kTR6OJsKE/n2kiL9DthmMgbfszMKfzxIWQYj4PQ19f1UFdSpQ/a+4zA1ekphWVfQEqG1iFqFj+kbKnO84EjA2lXmYq9IWxyTyxedd96VQhI4hfsc0ot3T6pAGjof/wBPiaetTAZdySPbhni7nUe9goy28YHL+wSC8Rbce9vO2vlnuscE0PEFlDHZ6uCr9uijGprAlmAHgFqYn5mex7llOJG59EVswsFcVKDsVihgQJHqUKXqrslsA/9KbQrLLo5I97c2ePelaXKKrZXyuj3KW6rit2fRVfUbzxG1ADse0c1qQtQrDZV3ZNuxzQJh4d+xd2X7HqqsacU3ruxQoMfss9ea09AbW/UUhbS/OBs8G/Nez8C5j0BDHQDNXKym0MS9lH+2Us0JDwxTG1EvYXquj9SKUkOoFu+fWSi2gFtBJn+I9Unz8e67nSA6lYkJ66STgV4aL3XT7gVIQZmql0I6qjPtcvZSi3ym0bBNwM5hGKYk6fUyEKhxw/AN+RvRhRaj1GPyMtEM4NIKBpOiTQ5q1/a8xxoiPd4Z0qNRM0y9Bdlv3YqzphRJ0FZYL6q6E7S0mOVJuEQOXLofD/PjFaHY3eQTvNJC/3FoVFtXNLSzUcfIhKzT9sl7OIPTqSKQ1LYOe4ERocPtML/ag1nIs8ETCefCL82DyMsxRroDFIgl8I4SsllYBg/vlmLvPiMVU6XPqkHw5rUuFD/ARHc8XZyx7q0yloyO+7ejXbQBm290ykKQT' ),
		seller: Profile.new( false, 'AgAAAA**AQAAAA**aAAAAA**gzqAVQ**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4GhDZiCoA6dj6x9nY+seQ**/mMDAA**AAMAAA**g8zWPzS6q0dMf0j0kt3VtE5wRbh0A6yhTP/xmS4PvGLZJpvgaTdteKRoS/c1aELoJXg+Z+83GW32PLCvS/WDEfu3gSs+cVR48cTw8ipS0J243zM1pbahGMP7IdIj7D5+auoDptcrqWCTBZbiGE5Efvb5MIiOYpmb97sI4WCelRMTGoachyE5U6sSj9nf79450iC8LNiaFAv6tC1Dk7UHzFTnoo10uj/8yQb8iu79k9Yki2Zhj1aKqF2eD+gjlkJqQUEhv5aifXe4mkFiz77xlCU82aOTne0nNjO1RNalZUCp3jylxL3blL6HyEm7SMy3IhQYt448DfoRhdejyBWU3fXNBhlTXiPxU4AJBan2lSJ5OPONrOGFop+1i9jPlGZxKPDhrkF3bbQ3/7iC7lUXGuucSaijs0Ud/OxEA9y+6VkabDtdhwk6M3YETscAf9797BZw5YzlEvEdmmQV3xDmC9gzEl/s8GkH0Yb4c2u0DPd+uf4DdqHY9fjuajElc2xjCWfWnCvWRHRNxKvJ4x6hwGWdTouVBlwHP+sPT0lnozu8B+QRWxAli6kECkYkErQyPk7hQvPOiV19LF9ur/gfFKYRnH0zHRsuvgN0uKT762yH6vyFaob8ePgbZACRwk+ioviS1mPlgriainvyk3Xwvu/aMXFG/scG7GXNOzfXUl2NQsR7z4Hw66jvB8Z4tGgspKF5zYx/kQ9fCTM56hou2MRR6WvrMfeOhzoOPF9mgudeSafQaw+PthKgEsCkpC87' )
	}
end


class Date

	attr_accessor :value

	def initialize( date )
		self.value = date
	end

	def year
		@value[/^\d+-/].sub('-', '')
	end

end

class Session

	attr_accessor 	:profile,
					:inventory, 
					:color_lists, 
					:quality_lists

	def initialize
		self.color_lists = Hash.new
		self.quality_lists = Hash.new
		self.inventory = Inventory.new
		
	end

	def color_list_to_s( name )
		str = "#{name}: "
		@color_lists[name].each do |value|
			str += "#{value},"
		end
		str.chop!

	end

	def quality_list_to_s( name )
		str = "#{name}: "
		@quality_lists[name].each do |value|
			str += "#{value},"
		end
		str.chop!

	end

end

class Profile

	attr_accessor :production, :token 

	def initialize( production, token )
		self.production = production
		self.token = token
	end

end
