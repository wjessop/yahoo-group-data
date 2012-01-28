#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rake/testtask'

Rake::TestTask.new do |t|
	t.libs << 'test'
end

desc "Run tests"
task :default => :test

desc "Fetch Yahoo Group pages for fixtures"
task :fetch_yahoo_pages do
	require 'yaml'
	require 'curb'
	groups = YAML.load_file('test/groups.yml')["groups"]
	total_groups = 0
	groups.each do |g|
		curb = Curl::Easy.new(g["url"])
  		curb.follow_location = true
  		curb.http_get

		File.open("test/yahoo_pages/#{g['id']}.html", "w") {|f| f.write curb.body_str }
		print "."
		total_groups += 1
	end
	puts
	puts "#{total_groups} group pages fetched"
end