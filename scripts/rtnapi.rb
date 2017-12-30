#!/usr/bin/env ruby

require 'json'
require 'open-uri'
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

  def uri(path)
    BASE_URI + path 
  end

  def schema_uri(year = nil)
    year ||= cur_year
    uri "schema/#{year}"
  end

  def team_uri(team_id, year = nil)
    year ||= cur_year
    uri "gymnasts/#{year}/#{team_id}"
  end

  def gymnast_uri(gymnast_id, year = nil)
    year ||= cur_year
    uri "gymnast/#{year}/#{gymnast_id}"
  end

  def parse(uri)
    JSON.load(open(uri).read)
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
    @gymnasts = teams.flat_map do |tname, tdata|
      tdata['gymnasts'].map do |data|
        name = RTNApi.clean_text(mdata.first.values_at('fname', 'lname').join)
        res = [
          name,
          {
            team: tname,
            id: data['id'],
            name: name,
            meets: {}
          }
        ]
        start_year.upto(cur_year) do |year|
          parse_gymnast_year(res, year)
        end
        res
      end.to_h
    end
  end

  def parse_gymnast_year(h, year)
    mdata = parse(gymnast_uri(data['id'], year))['meets']
    return if mdata.empty?
    res = {}
    events = ['all_around', 'vault', 'bars', 'beam', 'floor']
    mdata.each do |x|
      res[Time.at(x['meet_date'].to_i)] = events.map { |y| [y, x[y].to_i] }.to_h
    end
    h[meets][year] = res
  end
end
