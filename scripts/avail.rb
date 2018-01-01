#!/usr/bin/env ruby

require 'nokogiri'
require_relative 'rtnapi.rb'

class Avail
  def initialize
  end

  def source
    @source ||= 'data/draft_list.html'
  end

  def page
    @page ||= Nokogiri::HTML(open(source))
  end

  def teams
    @teams ||= page.at_css('ul.dropdown-menu').css('a')[1..-1].map do |x|
      [x['data-school'], x.text]
    end.to_h
  end

  def people
    @people ||= page.at_css('#hiddenSelectFrom').css('li').map do |x|
      {
        name: RTNApi.clean_text(x.text),
        team: RTNApi.clean_text(teams[x['data-school']])
      }
    end
  end
end
