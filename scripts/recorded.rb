#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'

Dir.chdir File.expand_path(File.dirname(__FILE__))

BASE_URL = 'http://www.roadtonationals.com/results/charts/ch_consistency_i.php'.freeze
BASE_TEAM_URL = "#{BASE_URL}?yr=2016&z=0&t=".freeze

def text_clean(text)
  text.downcase.gsub(/\s/, '').gsub(/\(.*\)/, '').gsub(/\W/, '')
end

teams = 1.upto(82).map { |x| Nokogiri::HTML(open(BASE_TEAM_URL + x.to_s)) }
people_ids = teams.flat_map do |x|
  team = text_clean(x.at_css('#teamsbox option[@selected]').text)
  team.gsub!('northcarolinastate', 'ncstate')
  x.at_css('#gymnast_filter').css('option').map do |y|
    "#{team}---#{text_clean(y.text)}---#{y['value']}"
  end
end.sort

File.open('../data/recorded.txt', 'w') do |fh|
  people_ids.sort.each do |name|
    fh << name + "\n"
  end
end
