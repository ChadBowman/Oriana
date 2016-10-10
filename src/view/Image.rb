require 'mini_magick'
require 'tk'
require 'securerandom'

class Image < MiniMagick::Image

	attr_reader :uri

	def initialize( path )

		if path =~ /http/
			img = MiniMagick::Image.open path
			new_path = "../temp/#{SecureRandom.uuid}.#{img.type.downcase}"
			img.write new_path
			super new_path
			puts "New path " + self.path
			@uri = path
			
		else
			super path

		end

	end

	def fmt() @format end

	def to_gif
		ret = MiniMagick::Image.new self.path
		ret.format 'gif'
		Image.new ret.path
	end

	def to_gif!
		format 'gif'
		self
	end

	def save( path )
		write path
	end

	def to_tk
		TkPhotoImage.new( file: @path )
	end

	def post( parent, index )
		
		if @format == 'gif'
			img = TkPhotoImage.new( file: self.path )
			TkTextImage.new( parent, index, image: img )
		else
			gif = self.to_gif
			img = TkPhotoImage.new( file: gif.path )
			TkTextImage.new( parent, index, image: img )
		end

	end

end


#require 'openssl'
#OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

#i = Image.new 'https://www.organicfacts.net/wp-content/uploads/2013/05/watermelon2.jpg'
#puts i.path