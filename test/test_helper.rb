# encoding: utf-8

require 'simplecov'
SimpleCov.start

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