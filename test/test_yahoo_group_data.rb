require 'test/unit'
require 'test_helper'
require 'webmock/test_unit'
require 'yahoo-group-data'
require 'date'
require 'yajl'

class YahooGroupDataTest < Test::Unit::TestCase

	def test_to_json		
		YAML.load_file('test/groups.yml')["groups"].each do |original_group|
			stub_request(:get, original_group["url"]).
				to_return(:status => 200, :body => File.read("test/yahoo_pages/#{original_group['id']}.html"), :headers => {})

			g = YahooGroupData.new(original_group["url"])
			data = Yajl::Parser.parse(g.to_json)

			assert_equal original_group['private'], data['private']
			assert_equal original_group['not_found'], data['not_found']
			assert_equal original_group['age_restricted'], data['age_restricted']
			assert_equal original_group['name'], data['name']
			assert_equal original_group['description'], data['description']
			assert_equal original_group['post_email'], data['post_email']
			assert_equal original_group['subscribe_email'], data['subscribe_email']
			assert_equal original_group['owner_email'], data['owner_email']
			assert_equal original_group['unsubscribe_email'], data['unsubscribe_email']
			assert_equal (original_group['founded'].nil? ? nil : original_group['founded'].strftime('%Y-%m-%d')), data['founded']
			assert_equal original_group['language'], data['language']
			assert_equal original_group['num_members'], data['num_members']
			assert_equal original_group['category'], data['category']
		end
	end

	def test_no_data
		YAML.load_file('test/groups.yml')["groups"].each do |original_group|
			stub_request(:get, original_group["url"]).
				to_return(:status => 200, :body => File.read("test/yahoo_pages/#{original_group['id']}.html"), :headers => {})

			g = YahooGroupData.new(original_group["url"])
			assert_equal g.no_data?, (original_group['private'] || original_group['not_found'] || original_group['age_restricted'])
		end
	end

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
		YAML.load_file('test/groups.yml')["groups"].each do |g_data|
			stub_request(:get, g_data["url"]).
			to_return(:status => 200, :body => File.read("test/yahoo_pages/#{g_data['id']}.html"), :headers => {})

			group = YahooGroupData.new(g_data["url"])
			assert_equal g_data["age_restricted"], group.age_restricted?
			assert_equal g_data["private"], group.private?
			assert_equal g_data["not_found"], group.not_found?
			assert_equal g_data["name"], group.name
			assert_equal g_data["description"], group.description
			assert_equal g_data["post_email"], group.post_email
			assert_equal g_data["subscribe_email"], group.subscribe_email
			assert_equal g_data["owner_email"], group.owner_email
			assert_equal g_data["unsubscribe_email"], group.unsubscribe_email
			assert_equal g_data["founded"], group.founded
			assert_equal g_data["language"], group.language
			assert_equal g_data["num_members"], group.num_members
			assert_equal g_data["category"], group.category
		end
	end

	def test_404
		missing_url = "http://tech.groups.yahoo.com/group/OneStopCOBOL/asdasd"
		stub_request(:get, missing_url).
			to_return(:status => 404, :body => "", :headers => {})
			group = YahooGroupData.new(missing_url)
			
			assert_nil group.age_restricted?
			assert_nil group.private?
			assert_nil group.name
			assert_nil group.description
			assert_nil group.post_email
			assert_nil group.subscribe_email
			assert_nil group.owner_email
			assert_nil group.unsubscribe_email
			assert_nil group.founded
			assert_nil group.language
			assert_nil group.num_members
			assert_nil group.category

			assert group.not_found?
			assert group.no_data?
	end
end
