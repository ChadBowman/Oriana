# Author::    Chad Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2015 Orthus Technology
# License::   Distributes under the same terms as Ruby

require 'tk'
require_relative 'Input'
require_relative 'TextManager'
require_relative '../control/Control'
require_relative 'Image'
require_relative '../model/Profile'

# Command-line terminal++
#
# Defaults:
#   Height 25 lines, Width 100 characters.
#   Output font Consolas, size 14
#   Input font Jura, size 15
class Console

    attr_accessor :profile

    # Parameters:
    # +title+:: title of window
    # +initial_text+:: text to display upon startup
    def initialize( 
        title = 'Console', initial_text = '', width = 0, height = 0 )

        # Create hash for prompts
        @commands = Array.new

        # Mono-spaced font for output
        mono = TkFont.new('family' => 'Consolas', 'size' => 14)
        # Jura for input
        jura = TkFont.new('family' => 'Jura', 'size' => 15)

        # Root pane
        @root = Tk::Root.new { title title }
        w = TkWinfo.screenwidth @root
        h = TkWinfo.screenheight @root
        
        if width == 0 or height == 0
            width = (w * 0.0765).to_i
            height = (h * 0.0315).to_i
        end

        @root.geometry "#{w-5}x#{h-120}+0+30"
        @root.iconphoto(TkPhotoImage.new('file' => 'src/orthus/icon.gif'))

        # Text window output
        @out = TextManager.new( @root, height, width, 0.8 ) do 
            font mono
            height height
            width width
            pack
        end

        # Print the splash page
        @out.splash initial_text

        # Text entry input
        @input = Tk::Entry.new( @root ) do 
            font jura    
            pack( side: 'bottom', fill: 'x' )
            focus
        end

        # Stack of call history
        history = Array.new
        # Call history pointer
        place = -1

        # Set key binds
        # Input capture
        @input.bind('Return') do
            history.push @input.get
            place = history.length
            @input.delete 0, 'end'
    
            run_command history.last
        
        end

        # History access
        @input.bind('Up') do
            if place > 0
                place -= 1
                @input.delete 0, 'end'
                @input.insert 0, history[place]
            end
        end

        # History return access
        @input.bind('Down') do
            if place < history.length - 1
                place += 1
                @input.delete 0, 'end'
                @input.insert 0, history[place]
            end
        end

        # Navigation binds
        #@input.bind('PgDown') { @out.next_sub }
        #@input.bind('Page-Up') { @out.previous_sub }
        @input.bind('Shift-Right') { @out.next }
        @input.bind('Shift-Left') { @out.previous }

    end # initialize

    def run_command( cmd )

        # Check input for action 
        @commands.each do |command|
            if cmd =~ command.prompt
                Thread.new do
                    begin
                        command.action Input.new( cmd )

                    rescue Exception => e
                        puts e
                        puts e.backtrace
                        raise e
                    end
                end
            end
        end
    end

    def profile=( profile )
        @profile = profile
        @commands.each{ |c| c.profile = @profile }        
    end

    # Adds command unless that regex source is exactly the same as another.
    #
    # Parameter:
    # +command+:: command to add to console
    def add_command( command )

        command.console = self
        command.entry = @input
        command.out = @out
        command.root = @root
        command.profile = @profile

        # If prompt is false, run once and dont add to stack
        unless command.prompt
            command.action
        else
            @commands.each do |com|
                if com.prompt == command.prompt
                    raise StandardError, "/#{com.prompt.source}/ is already a prompt in use!"
                end
            end

            @commands << command
        end # unless
    end # add_command

    # Run the main_pane loop, start the window
    def start() @root.mainloop end

end # Console