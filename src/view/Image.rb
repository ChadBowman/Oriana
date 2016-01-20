require 'mini_magick'
require 'tk'

class Image < MiniMagick::Image

	attr_reader :uri

	def initialize( path )
		if path =~ /http/
			super MiniMagick::Image.open( path ).path
			@uri = path
			
		else
			super path

		end

	end

	def fmt() @format end

	def to_gif
		ret = MiniMagick::Image.open self.path
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

#i = Image.new 'https://upload.wikimedia.org/wikipedia/commons/d/d5/Khajuraho-Lakshmana_temple.JPG'
#puts i.path