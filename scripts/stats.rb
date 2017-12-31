#!/usr/bin/env ruby

require_relative 'rtnapi.rb'

api = RTNApi.new
teams = api.teams
gymnsts = api.gymnasts

binding.pry
