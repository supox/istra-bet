class Tournament < ApplicationRecord
  has_many :rounds, dependent: :destroy

  def to_s
    self.name
  end

  def scores
    h = Hash.new(0)
    self.rounds.each do |round|
      round.games.each do |game|
        game.bets.each do |bet|
          h[bet.user_id] += bet.points
        end
      end
    end
    h.transform_keys {|user_id| User.find(user_id)}.sort_by{|k, v| -v}
  end
end
