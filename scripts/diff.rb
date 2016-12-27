#!/usr/bin/env ruby

Dir.chdir File.expand_path(File.dirname(__FILE__))

special = [
  ['arizonastate', 'nichellechristopherson', '23892'],
  ['bowlinggreen', 'indiamcpeak', '22843'],
  ['florida', 'rachelslocum', '22703'],
  ['georgewashington', 'brookebray', '22515'],
  ['michigan', 'paigezaziski', '22513'],
  ['michiganstate', 'tessajaranowski', '23096'],
  ['nebraska', 'abbieepperson', '22821'],
  ['newhampshire', 'brittanycapozzi', '24333'],
  ['ohiostate', 'amandahuang', '23911'],
  ['temple', 'morganfridey', '24133'],
  ['texaswomans', 'morgancolee', '23968'],
  ['utah', 'maceyroberts', '24191'],
  ['winonastate', 'devangreen', '24425']
]

avail = File.open('../data/avail.txt').map { |x| x.chomp.split('---') }
recorded = File.open('../data/recorded.txt').map { |x| x.chomp.split('---') }

wildcards = []
found = []

avail.each do |team, name|
  match = special.find { |rteam, rname, _| team == rteam && name == rname }
  if match
    found << [team, name, match.last]
    next
  end

  match = recorded.find { |rteam, rname, _| team == rteam && name == rname }
  if match
    found << match
    next
  end

  wildcards << [team, name]
end

File.open('../data/found.txt', 'w') do |fh|
  found.sort.each do |info|
    fh << info.join('---') + "\n"
  end
end

File.open('../data/wildcards.txt', 'w') do |fh|
  wildcards.sort.each do |info|
    fh << info.join('---') + "\n"
  end
end
