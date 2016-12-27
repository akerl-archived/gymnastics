#!/usr/bin/env ruby

require 'nokogiri'
require 'watir'
require 'execjs'
require 'fileutils'
require 'json'

Dir.chdir File.expand_path(File.dirname(__FILE__))

BROWSER = Watir::Browser.new
BASE_URL = 'http://www.roadtonationals.com/results/charts/ch_consistency_i.php'
BASE_PERSON_URL = "#{BASE_URL}?yr=2016&z=0&gid="

SCORE_START = /\A.*series: \[/m
SCORE_STOP = /\s+\]\s+}\);\s+}\);\s+}\);\s+\z/m

def load_page(id)
  BROWSER.goto BASE_PERSON_URL + id
  Nokogiri::HTML(BROWSER.html)
end

FileUtils.mkdir_p '../stats'
people_ids = File.readlines('../data/found.txt').map do |x|
  x.chomp.split('---')
end

def parse_score(page)
  score_script = page.css('script').find { |y| y.text =~ /Individual Event Score/ }
  score_raw = score_script.children.first.text.sub(SCORE_START, '').sub(SCORE_STOP, '')
  score_data = ExecJS.eval('[' + score_raw + ']').map do |y|
    [y['name'].downcase.to_sym, y['data']]
  end.to_h
end

people_ids.each do |team, name, id|
  puts "Loading id #{name} / #{team} / #{id}"
  dir = File.join('../stats', team)

  file = File.join(dir, name + '---' + id)
  next if File.exist? file

  page = load_page(id)
  data = { name: name, team: team }

  flag = page.at_css('.highcharts-subtitle').text
  data[:score] = parse_score(page) unless flag =~ /NO RECORDS/

  FileUtils.mkdir_p dir
  File.open(file, 'w') { |fh| fh << data.to_json }
end
