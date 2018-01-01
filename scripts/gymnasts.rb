require_relative 'rtnapi.rb'
require_relative 'avail.rb'

class Gymnasts
  def api
    @api ||= RTNApi.new
  end

  def teams
    @teams ||= api.teams
  end

  def api_gymnasts
    @api_gymnasts ||= api.gymnasts
  end

  def avail
    @avail ||= Avail.new.people
  end

  def injured
    @injured ||= File.read('data/injuries.txt').split("\n").map do |x|
      RTNApi.clean_text(x)
    end
  end

  def rtn_gymnasts
    @rtn_gymnasts ||= api_gymnasts.select do |x|
      next false if injured.include? x[:name]
      avail.find do |y|
        x[:name] == y[:name] && x[:team] == y[:team]
      end
    end
  end

  def gymnasts
    @gymnasts ||= rtn_gymnasts.map { |x| Gymnast.new x }
  end
end

EVENTS = [:vault, :bars, :beam, :floor].freeze

class Gymnast
  include Comparable

  attr_reader :name, :team, :scores, :all_scores

  def initialize(g)
    @name = g[:name]
    @team = g[:team]
    @all_scores = g[:meets]
    @scores = g[:meets].select { |k, v| k.year >= 2016 }.values
  end

  def real_scores(event)
    @scores.map { |x| x[event].zero? ? nil : x[event] }
  end

  def competes(freq_min = 0.8, score_min = 9.0)
    EVENTS.select do |event|
      full = real_scores(event)
      next false if full.empty?
      data = full.compact 
      next false unless data.size.to_f / full.size >= freq_min
      next false unless data.reduce(:+) / data.size >= score_min
      true
    end
  end

  def averages
    @averages ||= EVENTS.map do |event|
      data = real_scores(event).compact
      next [event, 0] if data.empty?
      [event, data.reduce(:+) / data.size]
    end.to_h
  end

  def <=>(other)
    return nil unless other.is_a? Gymnast
    my_avgs = averages.values.sort
    other_avgs = other.averages.values.sort
    my_avgs.zip(other_avgs).each do |my_score, other_score|
      res = my_score <=> other_score
      return -1 * res unless res.zero?
    end
    0
  end
end
