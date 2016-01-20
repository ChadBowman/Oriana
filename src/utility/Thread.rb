


class Thd


	def initialize( out )
		@out = out
		@flag = true
	end

	def func1
	   i=0
	   while i<=2
	      puts "func1 at: #{Time.now}"
	      sleep(2)
	      i=i+1
	   end
	end

	def func2
	   j=0
	   while j<=2
	      puts "func2 at: #{Time.now}"
	      sleep(2)
	      j=j+1
	   end
	   @flag = false
	end

	def loopy
		while @flag
			@out.prompt '.'
			sleep(1)
			@out.prompt '..'
			sleep(1)
			@out.prompt '...'
			sleep(1)
			@out.prompt ''
			sleep(1)
		end
	end

	def begin
		
		puts "Started At #{Time.now}"
		t1=Thread.new{loopy()}
		t2=Thread.new{func2()}
		t1.join
		t2.join
		puts "End at #{Time.now}"
	end

end