#!/usr/bin/env ruby

require_relative 'gymnasts.rb'
require 'pry'

info = Gymnasts.new
GYMNASTS = info.gymnasts

def find(name)
  GYMNASTS.find { |x| x.name.match name }
end

def find_all(name)
  GYMNASTS.select { |x| x.name.match name }
end

TEAMS = GYMNASTS.group_by(&:team)

draft = (
  # Folks who get 10s
  GYMNASTS.select { |x| EVENTS.select { |y| x.scores.map { |x| x[y] }.select { |z| z == 10 }.size > 0 }.size > 0 }.sort + \
  # Folks who compete great in 2+ events
  GYMNASTS.select { |x| x.competes(0.8, 9.8).size > 1 }.sort + \
  # Folks who compete excellently in any event
  GYMNASTS.select { |x| x.competes(0.7, 9.9).size > 0 }.sort + \
  # Folks who compete well in all 4 events
  GYMNASTS.select { |x| x.competes(0.8, 9.5).size > 3 }.sort + \
  # Folks who always compete in 3 or more events
  GYMNASTS.select { |x| x.competes(1.0, 9.6).size > 2 }.sort
)

# Collect frequent leaders from teams not already represented
freq_unrep = TEAMS.reject { |k, v| draft.group_by(&:team).keys.include? k }.map { |k, v| [k, v.select { |x| x.competes(0.9, 9.5).size > 1 }] }.reject { |k, v| v.empty? }.to_h.values.flatten
# Collect frequent leaders from teams with weak representation
freq_lowrep = TEAMS.reject { |k, v| (draft.group_by(&:team)[k] || [1] * 4).size > 2 }.map { |k, v| [k, v.select { |x| x.competes(0.9, 9.5).size > 2 }] }.reject { |k, v| v.empty? }.to_h.values.flatten
# Add above two collections to draft pool
draft += freq_unrep.sort + freq_lowrep.sort

# Add gymnasts who got equal to or better than 9.9 at least twice on at least 2 events
draft += GYMNASTS.select { |x| EVENTS.select { |y| x.scores.map { |x| x[y] }.select { |z| (z || 0) >= 9.9 }.size > 1 }.size > 1 }.sort

# Add gymnasts who got better than 9.9 at least twice on at least 1 events
draft += GYMNASTS.select { |x| EVENTS.select { |y| x.scores.map { |x| x[y] }.select { |z| (z || 0) > 9.9 }.size > 1 }.size > 0 }.sort

rand = Random.new(3)
count = 100
draft += GYMNASTS.sample(count, random: rand)
draft.uniq!
draft = draft.take(200)

g = GYMNASTS
t = TEAMS
d = draft
t = File.read('data/team').split("\n").map { |x| find RTNApi.clean_text(x) }

# rubocop:disable Lint/Debugger
binding.pry
