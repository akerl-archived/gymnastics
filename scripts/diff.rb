#!/usr/bin/env ruby

Dir.chdir File.expand_path(File.dirname(__FILE__))

special = [
  %w(arizonastate nichellechristopherson 23892),
  %w(bowlinggreen indiamcpeak 22843),
  %w(florida rachelslocum 22703),
  %w(georgewashington brookebray 22515),
  %w(michigan paigezaziski 22513),
  %w(michiganstate tessajaranowski 23096),
  %w(nebraska abbieepperson 22821),
  %w(newhampshire brittanycapozzi 24333),
  %w(ohiostate amandahuang 23911),
  %w(temple morganfridey 24133),
  %w(texaswomans morgancolee 23968),
  %w(utah maceyroberts 24191),
  %w(winonastate devangreen 24425)
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
