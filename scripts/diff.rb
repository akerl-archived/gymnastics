#!/usr/bin/env ruby

Dir.chdir File.expand_path(File.dirname(__FILE__))

special = [
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
