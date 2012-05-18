# encoding: utf-8
require 'yahoo-group-data/version'
require 'curb'
require 'uri'
require 'nokogiri'
require 'date'
require 'yajl'

class YahooGroupData
	def initialize(url)
		raise ArgumentError "A URL must be passed" unless url
		
		curb = Curl::Easy.new(url)
		curb.follow_location = true
		curb.http_get
		@html = curb.body_str.force_encoding('iso-8859-1').encode("UTF-8")
		@response_code = curb.response_code
	end

	def name
		@name ||= if not_found? || age_restricted?
				nil
			else
				doc.css('span.ygrp-pname').first.content
			end
	end

	def description
		element = doc.css('span.ygrp-grdescr')
		if element.size > 0
			doc.css('span.ygrp-grdescr').first.content.gsub(/\A[·\s]*/, "")
		end
	end

	def post_email
		@post_email ||= no_data? ? nil : subscribe_email.gsub("-subscribe@", "@")
	end

	def subscribe_email
		@subscribe_email ||= no_data? ? nil : doc.css('div#ygrp-links div.ygrp-contentblock').first.content.match(/(\S*-subscribe@[a-z]*yahoo[a-z]*\.[a-z\.]+)/)[1]
	end

	def owner_email
		@owner_email ||= no_data? ? nil : doc.css('div#ygrp-links div.ygrp-contentblock').first.content.match(/(\S*-owner@[a-z]*yahoo[a-z]*\.[a-z\.]+)/)[1]
	end

	def unsubscribe_email
		@unsubscribe_email ||= no_data? ? nil : doc.css('div#ygrp-links div.ygrp-contentblock').first.content.match(/(\S*-unsubscribe@[a-z]*yahoo[a-z]*\.[a-z\.]+)/)[1]
	end

	def private?
		return nil if not_found? || matches_age_restricted?
		matches_private?
	end

	def not_found?
		@not_found ||= (response_was_404? ||
			(
				doc.xpath('/html/body/div[3]/div/div/div/h3').size > 0 and
				doc.xpath('/html/body/div[3]/div/div/div/h3').first.content.strip.match(/Group Not Found|Group nicht gefunden/i)
			) ? true : false
		)
	end

	def age_restricted?
		return nil if not_found? or matches_private?
		matches_age_restricted?
	end

	def founded
		@founded ||= no_data? ? nil : Date.parse(date_str_to_english(doc.xpath("//ul[@class=\"ygrp-ul ygrp-info\"]//li[#{has_category? ? 3 : 2}]").inner_html.split(':')[1].strip))
	end

	def language
		@language ||= no_data? ? nil : doc.xpath("//ul[@class=\"ygrp-ul ygrp-info\"]//li[#{has_category? ? 4 : 3}]").inner_html.split(':')[1].strip
	end

	def num_members
		@num_members ||= no_data? ? nil : Integer(doc.xpath('//ul[@class="ygrp-ul ygrp-info"]//li[1]').inner_html.split(':')[1])
	end

	def category
		return unless has_category?
		@category ||= no_data? ? nil : doc.xpath('/html/body/div[3]/table/tr/td/div[2]/div[2]/div/ul/li[2]/a').inner_html
	end

	def to_json

		data_methods = %w{
			private?
			not_found?
			age_restricted?
			name
			description
			post_email
			subscribe_email
			owner_email
			unsubscribe_email
			language
			num_members
			category
			founded
		}

		data_hash = {}
		data_methods.map {|dm| data_hash[dm.tr('?', '')] = send(dm)}
		Yajl::Encoder.encode(data_hash)
	end

	def no_data?
		private? or age_restricted? or not_found?
	end

	private

	attr_reader :response_code

	def response_was_404?
		response_code == 404
	end

	def matches_private?
		@matches_private ||= (
			doc.xpath('/html/body/div[3]/center/p/big').size > 0 and
			doc.xpath('/html/body/div[3]/center/p/big').first.content.strip.match(/Sorry, this group is available to members ONLY./i)
		) ? true : false
	end

	def matches_age_restricted?
		@matches_age_restricted ||= (doc.xpath('/html/body/div[3]/div/div/div/h4').size > 0 and doc.xpath('/html/body/div[3]/div/div/div/h4').first.inner_html.strip.match(/You've reached an Age-Restricted Area/i)) ? true : false
	end

	# French:     jan,fév,mar,avr,mai,jun,jul,aoû,sep,oct,nov,déc
	# German:     jan,feb,mrz,apr,mai,jun,jul,aug,sep,okt,nov,dez
	# Portuguese: jan,fev,mar,abr,mai,jun,jul,ago,set,out,nov,dez
	# Spanish:    ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic
	# Swedish:    jan,feb,mar,apr,maj,jun,jul,aug,sep,okt,nov,dec
	# US / UK:    jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec

	def date_str_to_english(date_str)
		date_str.
			gsub(/ene/i, "Jan").
			gsub(/fév|fev/i, "Feb").
			gsub(/mar|mrz/i, "Mar").
			gsub(/avr|abr/i, "Apr").
			gsub(/mai|maj/i, "May").
			gsub(/aoû|ago/i, "Aug").
			gsub(/set/i, "Sep").
			gsub(/okt|out/i, "Oct").
			gsub(/déc|dez|dic/i, "Dec")
	end

	attr_reader :html, :doc

	def has_category?
		doc.xpath('//ul[@class="ygrp-ul ygrp-info"]//li').count == 3 ? false : true
	end

	def doc
		@doc ||= Nokogiri::HTML(html)
	end
end
