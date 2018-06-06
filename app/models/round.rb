class Round < ApplicationRecord
  belongs_to :tournament
  has_many :games, inverse_of: :round, dependent: :destroy
  validates_associated :tournament
  validates :name, length: { in: 2..100 }
  validates :name, :expiration_date, presence: true
  validate :expiration_date_on_future, on: :create
  validates_uniqueness_of :name, scope: [:tournament]
  accepts_nested_attributes_for :games, allow_destroy: true

  def to_s
    self.name
  end

  def open?
    self.expiration_date and self.expiration_date > DateTime.now
  end

  def bets(user)
    self.games.map do |game|
      Bet.find_or_create_by({game_id: game.id, user_id: user.id})
    end
  end

  def update_bets(new_bets, user)
    new_bets.transform_keys!(&:to_i)
    new_bets.transform_values!(&:to_i) 

    bets = self.bets(user)
    if new_bets.keys.sort != bets.map{|b| b.game_id}.sort
      self.errors.add(:base, "Illegal game ids: #{new_bets.keys}")
      return false
    end
    if not new_bets.values.to_set.subset? Bet.answers.values.to_set
      self.errors.add(:base, "Illegal answer values: #{new_bets.values}")
      return false
    end
    
    bets.each do |b|
      b.answer = new_bets[b.game_id]
      b.save!
    end
  end

  def expiration_date_on_future
    errors.add(:expiration_date, 'must be in the future') if not open?
  end

end
