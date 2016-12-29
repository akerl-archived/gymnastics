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
  attr_reader :name, :team, :scores, :wildcard

  def initialize(file)
    data = JSON.parse(File.read(file))
    @name = data['name']
    @team = data['team']
    @scores = Scores.new(data['score'])
    @wildcard = data['wildcard']
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

GYMNASTS = Dir.glob(STATS_DIR + '/*/*').map { |file| Gymnast.new file }
TEAMS = GYMNASTS.group_by(&:team)

mine = (
    # Folks who get 10s
    GYMNASTS.select { |x| EVENTS.select { |y| x.scores.send(y).select { |z| z == 10 }.size > 0 }.size > 0 } + \
    # Star freshmen
    %w(mykaylaskinner maggienichols ameliahundley).map { |x| find x } + \
    # Folks who compete great in 2+ events
    GYMNASTS.select { |x| x.competes(0.8, 9.8).size > 1 } + \
    # Folks who compete excellently in any event
    GYMNASTS.select { |x| x.competes(0.7, 9.9).size > 0 } + \
    # Folks who compete well in all 4 events
    GYMNASTS.select { |x| x.competes(0.8, 9.5).size > 3 } + \
    # Promising freshmen
    %w(kennediedney maddiekarr kimtessen taylorhouchin cassidykellen racheldickson graceglenn wynterchilders missyreinstadtler samogden).map { |x| find x } + \
    # Folks who always compete in 3 or more events
    GYMNASTS.select { |x| x.competes(1.0, 9.6).size > 2 }
)

# Collect frequent leaders from teams not already represented
freq_unrep = TEAMS.reject { |k, v| mine.group_by(&:team).keys.include? k }.map { |k, v| [k, v.select { |x| x.competes(0.9, 9.5).size > 1 }] }.reject { |k, v| v.empty? }.to_h.values.flatten
# Collect frequent leaders from teams with weak representation
freq_lowrep = TEAMS.reject { |k, v| (mine.group_by(&:team)[k] || [1] * 4).size > 2 }.map { |k, v| [k, v.select { |x| x.competes(0.9, 9.5).size > 2 }] }.reject { |k, v| v.empty? }.to_h.values.flatten
# Add above two collections to draft pool
mine += freq_unrep + freq_lowrep

# Add gymnasts who got equal to or better than 9.9 at least twice on at least 2 events
mine += GYMNASTS.select { |x| EVENTS.select { |y| x.scores.send(y).select { |z| (z || 0) >= 9.9 }.size > 1 }.size > 1 }

# Add gymnasts who got better than 9.9 at least twice on at least 1 events
mine += GYMNASTS.select { |x| EVENTS.select { |y| x.scores.send(y).select { |z| (z || 0) > 9.9 }.size > 1 }.size > 0 }

rand = Random.new(3)
count = 18
mine += GYMNASTS.sample(count, random: rand)

rejections = (
    # Injured athletes
    %w(sarahgarcia leahmacmoyle sydneyconverse micoleodell makenziekerouac meganfinck charlysantagado anniejuarez madisonpreston emilyliddle heatherelswick kylaross sheamahoney sofieriley gabbyhechtman kaseyjanowicz dianachesnok rachelfielitz hollyryan ashleylambert kaitlynnhedelund breshowers mckennasignley chanenraygoza emilybolton megankyle jackiesampson courtneysoliwoda kennaskepnek nikkimcnair alexisbrown mikaelagerber nicoletteswoboda)
)
mine.reject! { |x| rejections.include? x.name }

mine.uniq!

g = GYMNASTS
t = TEAMS
m = mine

p m.size

# rubocop:disable Lint/Debugger
binding.pry
