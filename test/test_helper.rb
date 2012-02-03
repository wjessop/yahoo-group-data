# encoding: utf-8

require 'simplecov'
SimpleCov.start do
	add_filter "/test/"
	add_filter "lib/yahoo-group-data/version.rb"
end
