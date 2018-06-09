class Tournament < ApplicationRecord
  has_many :rounds, dependent: :destroy
  strip_attributes

  validates :name, length: { in: 2..80 }
  validates :description, length: { in: 2..400 }
  validates :name, :description, presence: true

  def to_s
    name
  end

  def scores
    h = Hash.new(0)
    rounds.each do |round|
      round.games.each do |game|
        game.bets.each do |bet|
          h[bet.user_id] += bet.points
        end
      end
    end
    h.transform_keys { |user_id| User.find(user_id) }.sort_by { |_k, v| -v }
  end
end
