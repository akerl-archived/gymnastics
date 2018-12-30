#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'fileutils'
require 'date'
require 'cymbal'
require 'parallel'

class RTNApi
  BASE_URI = 'https://www.roadtonationals.com/api/women/'

  def initialize
  end

  def cur_year
    2019
  end

  def start_year
    @start_year ||= cur_year - 3
  end

  def self.clean_text(text)
    text.downcase.gsub(/\s/, '').gsub(/\(.*\)/, '').gsub(/\W/, '')
  end

  def schema_uri(year = nil)
    year ||= cur_year
    "schema/#{year}"
  end

  def team_uri(team_id, year = nil)
    year ||= cur_year
    "gymnasts/#{year}/#{team_id}"
  end

  def gymnast_uri(gymnast_id, year = nil)
    year ||= cur_year
    "gymnast/#{year}/#{gymnast_id}"
  end

  def check_cache(uri)
    cache_file = File.join('stats', uri)
    return nil unless File.exist? cache_file
    cache_file
  end

  def write_cache(uri, res)
    cache_file = File.join('stats', uri)
    FileUtils.mkdir_p File.dirname(cache_file)
    File.open(cache_file, 'w') { |fh| fh << JSON.dump(res) }
  end

  def parse(uri)
    cache_file = check_cache uri
    source = cache_file || BASE_URI + uri
    puts "Downloading #{source}" unless cache_file
    res = JSON.load(open(source).read)
    write_cache(uri, res) unless cache_file
    res
  end

  def schema
    @schema ||= parse(schema_uri)
  end

  def teams
    return @teams if @teams
    @teams = schema['teams'].map do |k, v|
      name = RTNApi.clean_text(v)
      id = k[1..-1]
      data = parse(team_uri(id))
      data['name'] = name
      data['id'] = id
      [name, data]
    end.to_h
    @teams = Cymbal.symbolize @teams
  end

  def gymnasts
    return @gymnasts if @gymnasts
    #@gymnasts = Parallel.map(teams, in_threads: 10) do |a|
    @gymnasts = teams.map do |a|
      tname, tdata = a
      tdata[:gymnasts].map do |data|
        name = RTNApi.clean_text(data.values_at(:fname, :lname).join)
        res = {
          team: tname.to_s,
          teamid: tdata[:id],
          id: data[:id],
          name: name,
          meets: {}
        }
        start_year.upto(cur_year) do |year|
          parse_gymnast_year(res, year)
        end
        res
      end
    end.flatten
  end

  def parse_gymnast_year(res, year)
    meets = parse_gymnast_data(res[:id], year)
    meets ||= parse_gymnast_old_id(res, year)
    meets ||= {}
    res[:meets].merge!(meets)
  end

  def parse_gymnast_data(id, year)
    mdata = parse(gymnast_uri(id, year))['meets']
    return if mdata.empty?
    events = ['all_around', 'vault', 'bars', 'beam', 'floor']
    meets = {}
    mdata.each do |x|
      meets[Time.at(x['meet_date'].to_i)] = events.map { |y| [y.to_sym, x[y].to_f] }.to_h
    end
    meets
  end

  def parse_gymnast_old_id(res, year)
    old_team = parse(team_uri(res[:teamid], year))
    old_names = old_team["gymnasts"].map do |x|
      [RTNApi.clean_text(x.values_at('fname', 'lname').join), x['id']]
    end.to_h
    old_id = old_names[res[:name]]
    return unless old_id
    parse_gymnast_data(old_id, year)
  end
end
