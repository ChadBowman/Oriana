@echo off
bundle -v >nul 2>&1 || (
    gem install bundler
) & (
    bundler install
    ruby src/Oriana.rb
)