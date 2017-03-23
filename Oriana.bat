@echo off
bundle -v >nul 2>&1 || gem install bundler
bundle install
ruby src/Oriana.rb
