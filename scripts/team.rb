#!/usr/bin/env ruby

require_relative 'gymnasts.rb'
require 'pry'

info = Gymnasts.new
GYMNASTS = info.gymnasts

def find(name)
  GYMNASTS.find { |x| x.name.match name }
end

t = File.read('data/team').split("\n").map { |x| find RTNApi.clean_text(x) }

binding.pry
