#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'fileutils'
require 'date'
require 'cymbal'

class RTNApi
  BASE_URI = 'https://www.roadtonationals.com/api/women/'

  def initialize
  end

  def cur_year
    @cur_year ||= Date.today.year
  end

  def start_year
    @start_year ||= cur_year - 5
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
    cache_file = File.join('cache', uri)
    return nil unless File.exist? cache_file
    cache_file
  end

  def write_cache(uri, res)
    cache_file = File.join('cache', uri)
    FileUtils.mkdir_p File.dirname(cache_file)
    File.open(cache_file, 'w') { |fh| fh << JSON.dump(res) }
  end

  def parse(uri)
    cache_file = check_cache uri
    source = cache_file || BASE_URI + uri
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
      puts "Loading team #{name}"
      data = parse(team_uri(id))
      data['name'] = name
      data['id'] = id
      [name, data]
    end.to_h
    @teams = Cymbal.symbolize @teams
  end

  def gymnasts
    return @gymnasts if @gymnasts
    @gymnasts = teams.flat_map do |tname, tdata|
      tdata[:gymnasts].map do |data|
        name = RTNApi.clean_text(data.values_at(:fname, :lname).join)
        res = {
          team: tname,
          id: data[:id],
          name: name,
          meets: {}
        }
        start_year.upto(cur_year) do |year|
          parse_gymnast_year(res, year)
        end
        [name, res]
      end.to_h
    end
    @gymnasts = Cymbal.symbolize @gymnasts
  end

  def parse_gymnast_year(res, year)
    puts "Checking #{res[:name]} from #{res[:team]} for #{year}"
    mdata = parse(gymnast_uri(res[:id], year))['meets']
    return if mdata.empty?
    ydata = {}
    events = ['all_around', 'vault', 'bars', 'beam', 'floor']
    mdata.each do |x|
      ydata[Time.at(x['meet_date'].to_i)] = events.map { |y| [y, x[y].to_i] }.to_h
    end
    res[:meets][year] = res
  end
end
