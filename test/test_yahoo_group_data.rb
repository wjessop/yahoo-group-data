require 'test/unit'
require 'test_helper'
require 'webmock/test_unit'
require 'yahoo-group-data'
require 'date'

class YahooGroupDataTest < Test::Unit::TestCase
	def test_initialize_with_invalid_params
		assert_raise(ArgumentError)  { YahooGroupData.new }
	end

	def test_initialize_with_valid_params
		url = "http://tech.groups.yahoo.com/group/OneStopCOBOL/"

		stub_request(:get, url).
		to_return(:status => 200, :body => "", :headers => {})

		g = YahooGroupData.new(url)
		assert_equal g.class, YahooGroupData
		assert_requested :get, url
	end

	def test_handling_redirects
		url = "http://tech.groups.yahoo.com/group/OneStopCOBOL"
		stub_request(:get, url).
		to_return(:status => 302, :headers => { 'Location' => "#{url}/" })
		stub_request(:get, "#{url}/").
		to_return(:status => 200, :body => "", :headers => {})

		g = YahooGroupData.new(url)
		assert_equal g.class, YahooGroupData
		assert_requested :get, url
		assert_requested :get, "#{url}/"
	end

	# This method will loop over all the html files
	# (see the README on how to download them)
	# then runs the assertions on each one.
	def test_data_extraction
		groups = YAML.load_file('test/groups.yml')["groups"]
		groups.each do |g_data|
			puts "fetching #{g_data["url"]}"
			stub_request(:get, g_data["url"]).
			to_return(:status => 200, :body => File.read("test/yahoo_pages/#{g_data['id']}.html"), :headers => {})

			group = YahooGroupData.new(g_data["url"])
			if g_data["not_found"]
				assert_equal g_data["not_found"], group.not_found?
			elsif g_data["private"]
				assert_equal g_data["not_found"], group.not_found?
				assert_equal g_data["private"], group.private?
			elsif g_data["age_restricted"]
				assert_equal g_data["not_found"], group.not_found?
				assert_equal g_data["age_restricted"], group.age_restricted?
			else
				assert_equal g_data["age_restricted"], group.age_restricted?
				assert_equal g_data["private"], group.private?
				assert_equal g_data["not_found"], group.not_found?
				assert_equal g_data["name"], group.name
				assert_equal g_data["description"], group.description
				assert_equal g_data["post_email"], group.post_email
				assert_equal g_data["subscribe_email"], group.subscribe_email
				assert_equal g_data["owner_email"], group.owner_email
				assert_equal g_data["unsubscribe_email"], group.unsubscribe_email
				assert_equal Date.parse(date_str_to_english(g_data["founded"])), group.founded
				assert_equal g_data["language"], group.language
				assert_equal g_data["num_members"], group.num_members
				assert_equal g_data["category"], group.category
			end
		end
	end
end