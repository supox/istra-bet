class Game < ApplicationRecord
  belongs_to :round, inverse_of: :games
  validates_associated :round
  has_many :bets, :dependent => :destroy

  validates :description, length: { in: 2..40 }
  validates :team1, :team2, length: { in: 2..20 }
  validate :not_the_same_team
  validates :description, :team1, :team2, :start_time, :bet_points, presence: true
  validates :bet_points, numericality: { greater_than: 0 }

  enum result: { unknown: 0, team1: 1, team2: 2, tie: 3 }

  def result_name
    return "-" if result.nil?
    case result.to_sym
    when :team1 then team1
    when :team2 then team2
    when :tie then "Tie"
    else "-"
    end
  end

  def short_description
    "#{team1} vs #{team2}"
  end

  def not_the_same_team
    errors.add(:team2, 'must not be the same as team1') if team1 == team2
  end
end
