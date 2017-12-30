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
        mdata = parse(gymnast_uri(data['id']))['meets']
        mdata.each do |x|
          x['team'] = tname
          x['id'] = data['id']
          x['name'] = RTNApi.clean_text(x['fname'] + x['lname'])
          ['all_around', 'vault', 'bars', 'beam', 'floor'].each { |y| x[y] = x[y].to_i }
          x['meet_date'] = Time.at(x['meet_date'].to_i)
        end
        name = RTNApi.clean_text(mdata.first.values_at('fname', 'lname').join)
        [
          name,
          {
            team: tname,
            id: data['id'],
            name: name,
            meets: mdata
          }
        ]
      end
    end.to_h
    @gymnasts = Cymbal.symbolize @gymnasts
  end
end
