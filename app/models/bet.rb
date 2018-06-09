class Bet < ApplicationRecord
  belongs_to :game
  belongs_to :user

  validates_associated :game, :user

  enum answer: { team1: 1, team2: 2, tie: 3 }
  validates :answer, presence: true, inclusion: Bet.answers.keys
  validates_uniqueness_of :game, scope: :user

  def answer_hash
    { game.team1 => 1, game.team2 => 2, Tie: 3 }
  end

  def answer_name
    return "-" if answer.nil?
    case answer.to_sym
    when :team1 then game.team1
    when :team2 then game.team2
    when :tie then "Tie"
    else answer
    end
  end

  def points
    if answer.to_s == game.result.to_s
      game.bet_points
    else
      0
    end
  end
end
