#!/usr/bin/env ruby

require 'pry'
require 'json'

Dir.chdir File.expand_path(File.dirname(__FILE__))

STATS_DIR = '../stats'.freeze

##
# Helper class for accessing scores
class Scores
  attr_reader :vault, :bars, :beam, :floor
  def initialize(scores)
    scores ||= {}
    @vault = scores['vault']
    @bars = scores['bars']
    @beam = scores['beam']
    @floor = scores['floor']
  end
end

##
# Helper class for accessing gymnasts
class Gymnast
  attr_reader :name, :team
  def initialize(file)
    data = JSON.parse(File.read(file))
    @name = data['name']
    @team = data['team']
    @scores = Scores.new(data['score'])
  end
end

gymnasts = Dir.glob(STATS_DIR + '/*/*').map { |file| Gymnast.new file }
teams = gymnasts.group_by(&:team)

# rubocop:disable Lint/Debugger
g = gymnasts
t = teams
binding.pry
