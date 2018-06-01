class Game < ApplicationRecord
  belongs_to :round, inverse_of: :games, dependent: :destroy
  has_many :bets
  validates_associated :round

  enum result: {unknown: 0, team1: 1, team2: 2, tie: 3}

  def result_name
    return "-" if self.result.nil?
    case self.result.to_sym
      when :team1 then self.team1
      when :team2 then self.team2
      when :tie then "Tie"
      else "-"
    end
  end

end
