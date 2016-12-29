#!/usr/bin/env ruby

require 'nokogiri'
require 'watir'
require 'execjs'
require 'fileutils'
require 'json'

Dir.chdir File.expand_path(File.dirname(__FILE__))

BASE_URL = 'http://www.roadtonationals.com/results/charts/ch_consistency_i.php'.freeze
BASE_PERSON_URL = "#{BASE_URL}?yr=2016&z=0&gid=".freeze

SCORE_START = /\A.*series: \[/m
SCORE_STOP = /\s+\]\s+}\);\s+}\);\s+}\);\s+\z/m

def browser
  @browser ||= Watir::Browser.new
end

def load_page(id)
  browser.goto BASE_PERSON_URL + id
  Nokogiri::HTML(browser.html)
end

def load_file(file)
  File.readlines('../data/' + file).map do |x|
    x.chomp.split('---')
  end
end

FileUtils.mkdir_p '../stats'
people_ids = load_file 'found.txt'
wildcards = load_file 'wildcards.txt'

def extract_script(page)
  score_script = page.css('script').find do |y|
    y.text =~ /Individual Event Score/
  end
  score_raw = score_script.children.first.text
  score_raw.sub(SCORE_START, '').sub(SCORE_STOP, '')
end

def parse_score(page)
  ExecJS.eval('[' + extract_script(page) + ']').map do |y|
    [y['name'].downcase.to_sym, y['data']]
  end.to_h
end

def get_stat_path(team, name, id = '0')
  dir = File.join('../stats', team)
  FileUtils.mkdir_p dir
  File.join(dir, name + '---' + id)
end

people_ids.each do |team, name, id|
  puts "Loading id #{name} / #{team} / #{id}"
  file = get_stat_path(team, name, id)
  next if File.exist? file

  page = load_page(id)
  data = { name: name, team: team }

  flag = page.at_css('.highcharts-subtitle').text
  data[:score] = parse_score(page) unless flag =~ /NO RECORDS/

  File.open(file, 'w') { |fh| fh << data.to_json }
end

wildcards.each do |team, name|
  puts "Creating file for wildcard #{name} / #{team}"
  data = { name: name, team: team }
  File.open(get_stat_path(team, name), 'w') { |fh| fh << data.to_json }
end
