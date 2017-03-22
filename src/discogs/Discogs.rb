# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2016 Orthus Technology
# License::   Distributes under the same terms as Ruby

require 'Discogs'
require 'openssl'

# Manages search queries to Discogs.com's database.
class Discog

    def initialize
        @wrapper = Discogs::Wrapper.new( 'Cactus Records',
            user_token: 'feTyIlGcQIbOEVByLnSxxTtazBxDmxZwZkZYcfxl' )
    end

    # Perform a barcode inquiry.
    #
    # ==== Parameters
    # * +barcode+ - [String (Required)] Barcode to search.
    #
    # ==== Returns
    # * _Array_ - Hashie results.
    def search( barcode )

        if barcode =~ /\d+/
            # Search for specfic matches first.
            results = @wrapper.search( nil, barcode: barcode, type: :release )

            # If specific search fails, go more broad
            if results[:pagination][:items] == 0
                results = @wrapper.search( barcode, type: :release )
            end
        else
            results = @wrapper.search( barcode, type: :release )
        end

        # TODO make a more elegant fix for too many results.
        # Throw error if results more than this search shows.
        #throw StandardError, 'Too many results!' if results[:pagination][:pages] > 1

        # Return array of results.
        results[:results]
    end

    def get_release( id )
        @wrapper.get_release id
    end

    def get_master( id )
        @wrapper.get_master_release id
    end
end

#OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
#puts Discog.new.search('The replacements sorry ma, forgot to take out the trash')
#puts Discog.new.get_release('7696080')