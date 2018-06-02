class Bet < ApplicationRecord
  belongs_to :game
  belongs_to :user

  validates_associated :game, :user

  enum answer: {team1: 1, team2: 2, tie: 3}
  validates :answer, presence: true, inclusion: Bet.answers.keys
  validates_uniqueness_of :game, uniqueness: { scope: :user }



  def answer_hash
    {self.game.team1 => 1, self.game.team2 => 2, Tie: 3}
  end

  def answer_name
    return "-" if self.answer.nil?
    case self.answer.to_sym
      when :team1 then self.game.team1
      when :team2 then self.game.team2
      when :tie then "Tie"
      else self.answer
    end
  end

  def points
    if self.answer.to_s == self.game.result.to_s
      self.game.bet_points
    else
      0
    end
  end
end
