# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2015 Orthus Technology
# License::   Distributes under the same terms as Ruby

module Oriana

	VERSION = '1.0'

	WELCOME = <<-END 
                Orthus Technology
             _____   ______ _____ _______ __   _ _______
            |     | |_____/   |   |_____| | \\  | |_____|
            |_____| |    \\_ __|__ |     | |  \\_| |     |

                                         Version: #{VERSION}
END

end

module Ebay

	GOOD_TIL_CANCELED = 'GTC'
	FIXED = 'FixedPriceItem'
	AUCTION = 'Chinese'
	DAYS_7 = 'Days_7'
	DAYS_10 = 'Days_10'
	DAYS_5 = 'Days_5'
end

module Cactus

	EBAY_VINYL_CATEGORY = '176985'
	EBAY_CD_CATEGORY = '176984'

	VINYL = '4646348015'
	CDS =   '4646347015'
	ROCK = '4527246015'
	COUNTRY = '4527247015'
	JAZZ = '4528456015'
	HIPHOP = '4527257015'
	ELECTRONIC = '4527259015'
	POP = '10858862015'
	BLUES = '4528457015'
end

module Orthus

	RUNAME = 'Orthus_Technolo-OrthusTe-b249-4-jngrp'
	PRODUCTION_APP_ID = 'OrthusTe-b249-4e73-a34e-763549ce8b1e'
	PRODUCTION_CERT_ID = '3f3a6c4d-1b02-40dc-8b8c-295cc7043dd3'
	SANDBOX_APP_ID = 'OrthusTe-96ce-48db-a0e4-82dbbcb37804'
	SANDBOX_CERT_ID = 'e6547f74-f0f3-473f-9b73-03814cd78dc6'
	TOKEN = 'AgAAAA**AQAAAA**aAAAAA**AaJ4VQ**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6AFkIOnD5WKoAqdj6x9nY+seQ**W8oCAA**AAMAAA**ZPA6X9PG7HZ1yZZFO94/Ntq2ks/p7GS6Ke3yf80Uql7ow77sMKOZkH0vIP275Ho36JKbyu5brwSEzENty/NZFgsVo6Dbik0c7VFAfr8KobRiUVwD8T+0e5rsSz/7wsAO4gX6V0O1YYLX95OwZx0dsMA7OCpuXh32HPhDrzWnjEfXrpFiSDKQ5c287U6aeSNRBziInqqWpvdj9JxeeIUs61rx5exQqKpAKCdNoElnvMfC2SMbWkV83xUaH5xqnYVe2VUNuQZvFGkh/KZIWLsssC/Dexrcg31iM+aidVIj83A7pfIWNkgM0C5ZPiPjEq//YWM0gS6NIoFYgyvGxpq2mw+KrsIxxLdMxlTx4YWaVDfKz7n8VUm0ozKioXGaQrbwPodHY4a/Uw6Cbv77ChTho7hzRc9bNqznNkVrv4tKthNbDAT1HN7TVL0M9DoahywlnzPPQj5kyuKCUC+D9bADjEtKTLTk/9TOn+OwTs1M6aVxJajo22r7CpxnQgQQL3OyViPVKAzukDUyKAQ9RznV5I9Lu+9SVBv7Xwb2uRS69qipDy/jOm092kOhZjl8GfD+eqlXj66WwkPbHlz/wQFxhow7Td5Lmn24qCTQId6192W/0AlduIk7QlPxgkLdRVn5Lq/REXvFiyM37OIpA+UL08kPcTALd6hXMWAXqWn10FjCe12mhJi1ibWp6sWmx+xk5OQEfilmArQFZsjCBje2KReIIrNGPJcJnpT+VsUljcHoRKTr6rH7KOi9imjxqvMo'
	BUYER_TOKEN = 'AgAAAA**AQAAAA**aAAAAA**kD8lVQ**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4GhDZWGpQ2dj6x9nY+seQ**/mMDAA**AAMAAA**2GScRUabHVT/RRkzlq4kTR6OJsKE/n2kiL9DthmMgbfszMKfzxIWQYj4PQ19f1UFdSpQ/a+4zA1ekphWVfQEqG1iFqFj+kbKnO84EjA2lXmYq9IWxyTyxedd96VQhI4hfsc0ot3T6pAGjof/wBPiaetTAZdySPbhni7nUe9goy28YHL+wSC8Rbce9vO2vlnuscE0PEFlDHZ6uCr9uijGprAlmAHgFqYn5mex7llOJG59EVswsFcVKDsVihgQJHqUKXqrslsA/9KbQrLLo5I97c2ePelaXKKrZXyuj3KW6rit2fRVfUbzxG1ADse0c1qQtQrDZV3ZNuxzQJh4d+xd2X7HqqsacU3ruxQoMfss9ea09AbW/UUhbS/OBs8G/Nez8C5j0BDHQDNXKym0MS9lH+2Us0JDwxTG1EvYXquj9SKUkOoFu+fWSi2gFtBJn+I9Unz8e67nSA6lYkJ66STgV4aL3XT7gVIQZmql0I6qjPtcvZSi3ym0bBNwM5hGKYk6fUyEKhxw/AN+RvRhRaj1GPyMtEM4NIKBpOiTQ5q1/a8xxoiPd4Z0qNRM0y9Bdlv3YqzphRJ0FZYL6q6E7S0mOVJuEQOXLofD/PjFaHY3eQTvNJC/3FoVFtXNLSzUcfIhKzT9sl7OIPTqSKQ1LYOe4ERocPtML/ag1nIs8ETCefCL82DyMsxRroDFIgl8I4SsllYBg/vlmLvPiMVU6XPqkHw5rUuFD/ARHc8XZyx7q0yloyO+7ejXbQBm290ykKQT'
	SELLER_TOKEN = 'AgAAAA**AQAAAA**aAAAAA**gzqAVQ**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4GhDZiCoA6dj6x9nY+seQ**/mMDAA**AAMAAA**g8zWPzS6q0dMf0j0kt3VtE5wRbh0A6yhTP/xmS4PvGLZJpvgaTdteKRoS/c1aELoJXg+Z+83GW32PLCvS/WDEfu3gSs+cVR48cTw8ipS0J243zM1pbahGMP7IdIj7D5+auoDptcrqWCTBZbiGE5Efvb5MIiOYpmb97sI4WCelRMTGoachyE5U6sSj9nf79450iC8LNiaFAv6tC1Dk7UHzFTnoo10uj/8yQb8iu79k9Yki2Zhj1aKqF2eD+gjlkJqQUEhv5aifXe4mkFiz77xlCU82aOTne0nNjO1RNalZUCp3jylxL3blL6HyEm7SMy3IhQYt448DfoRhdejyBWU3fXNBhlTXiPxU4AJBan2lSJ5OPONrOGFop+1i9jPlGZxKPDhrkF3bbQ3/7iC7lUXGuucSaijs0Ud/OxEA9y+6VkabDtdhwk6M3YETscAf9797BZw5YzlEvEdmmQV3xDmC9gzEl/s8GkH0Yb4c2u0DPd+uf4DdqHY9fjuajElc2xjCWfWnCvWRHRNxKvJ4x6hwGWdTouVBlwHP+sPT0lnozu8B+QRWxAli6kECkYkErQyPk7hQvPOiV19LF9ur/gfFKYRnH0zHRsuvgN0uKT762yH6vyFaob8ePgbZACRwk+ioviS1mPlgriainvyk3Xwvu/aMXFG/scG7GXNOzfXUl2NQsR7z4Hw66jvB8Z4tGgspKF5zYx/kQ9fCTM56hou2MRR6WvrMfeOhzoOPF9mgudeSafQaw+PthKgEsCkpC87'
	SANDBOX_PP_EMAIL = 'seller@orthus.net'
	# Password: orthus usual
end