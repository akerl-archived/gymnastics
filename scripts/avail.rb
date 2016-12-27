#!/usr/bin/env ruby

require 'nokogiri'

Dir.chdir File.expand_path(File.dirname(__FILE__))

page = Nokogiri::HTML(open('../data/draft_list.html'))

teams = page.at_css('ul.dropdown-menu').css('a')[1..-1].map do |x|
  [x['data-school'], x.text]
end.to_h
people = page.at_css('#hiddenSelectFrom').css('li').map do |x|
  { name: x.text, team: teams[x['data-school']] }
end

def text_clean(text)
  text.downcase.gsub(/\s/, '').gsub(/\(.*\)/, '').gsub(/\W/, '')
end

clean_names = people.map do |info|
  info.values_at(:team, :name).map { |x| text_clean(x) }.join('---')
end

File.open('../data/avail.txt', 'w') do |fh|
  clean_names.sort.each do |name|
    fh << name + "\n"
  end
end
