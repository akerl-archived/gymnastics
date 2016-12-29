#!/usr/bin/env ruby

require 'pry'
require 'json'

Dir.chdir File.expand_path(File.dirname(__FILE__))

STATS_DIR = '../stats'.freeze

EVENTS = [:vault, :bars, :beam, :floor].freeze

##
# Helper class for accessing scores
class Scores
  attr_reader :vault, :bars, :beam, :floor
  def initialize(scores)
    scores ||= {}
    @vault = scores['vault'] || []
    @bars = scores['bars'] || []
    @beam = scores['beam'] || []
    @floor = scores['floor'] || []
  end
end

##
# Helper class for accessing gymnasts
class Gymnast
  attr_reader :name, :team, :scores

  def initialize(file)
    data = JSON.parse(File.read(file))
    @name = data['name']
    @team = data['team']
    @scores = Scores.new(data['score'])
  end

  def competes(freq_min = 0.8, score_min = 9.0)
    EVENTS.select do |event|
      full = @scores.send(event)
      next false if full.empty?
      data = full.compact
      next false unless data.size.to_f / full.size >= freq_min
      next false unless data.reduce(:+) / data.size >= score_min
      true
    end
  end
end

def find(name)
  GYMNASTS.find { |x| x.name.match name }
end

def find_all(name)
  GYMNASTS.select { |x| x.name.match name }
end

gymnasts = Dir.glob(STATS_DIR + '/*/*').map { |file| Gymnast.new file }
GYMNASTS = gymnasts
teams = gymnasts.group_by(&:team)
TEAMS = teams

# rubocop:disable Lint/Debugger
g = gymnasts
t = teams
binding.pry
