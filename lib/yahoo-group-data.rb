# encoding: utf-8
require 'yahoo-group-data/version'
require 'curb'
require 'uri'
require 'nokogiri'

class YahooGroupData
	def initialize(url)
		raise ArgumentError "A URL must be passed" unless url
		
		curb = Curl::Easy.new(url)
		curb.follow_location = true
		curb.http_get
		@html = curb.body_str
	end

	def name
		doc.css('span.ygrp-pname').first.content
	end

	def description
		element = doc.css('span.ygrp-grdescr')
		if element.size > 0
			doc.css('span.ygrp-grdescr').first.content.gsub(/\A[·\s]*/, "")
		end
	end

	def post_email
		subscribe_email.gsub("-subscribe@", "@")
	end

	def subscribe_email
		doc.css('div#ygrp-links div.ygrp-contentblock').first.content.match(/(\S*-subscribe@[a-z]*yahoo[a-z]*\.[a-z\.]+)/)[1]
	end

	def owner_email
		doc.css('div#ygrp-links div.ygrp-contentblock').first.content.match(/(\S*-owner@[a-z]*yahoo[a-z]*\.[a-z\.]+)/)[1]
	end

	def unsubscribe_email
		doc.css('div#ygrp-links div.ygrp-contentblock').first.content.match(/(\S*-unsubscribe@[a-z]*yahoo[a-z]*\.[a-z\.]+)/)[1]
	end

	def private?
		@private_group ||= (
			not_found_element = doc.xpath('/html/body/div[3]/center/p/big')
			not_found_element.size > 0 and not_found_element.first.content.strip.match(/Sorry, this group is available to members ONLY./i) ? true : false
		)
	end

	def defunct?
		@defunct ||= (
			not_found_element = doc.xpath('/html/body/div[3]/div/div/div/h3')
			not_found_element.size > 0 and not_found_element.first.content.strip.match(/Group Not Found|Group nicht gefunden/i) ? true : false
		)
	end

	private

	attr_reader :html, :doc

	def doc
		@doc ||= Nokogiri::HTML(html)
	end
end
