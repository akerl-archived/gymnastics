#!/usr/bin/env ruby

require_relative 'rtnapi.rb'
require 'pry'

api = RTNApi.new
teams = api.teams
gymnasts = api.gymnasts

binding.pry
