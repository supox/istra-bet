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
    name
  end

  def open?
    expiration_date && (expiration_date > DateTime.now)
  end

  def bets(user)
    games.map do |game|
      Bet.find_or_create_by(game_id: game.id, user_id: user.id)
    end
  end

  def update_bets(new_bets, user)
    unless open?
      errors.add(:base, "Round already closed.")
      return false
    end
    new_bets.transform_keys!(&:to_i)
    new_bets.transform_values!(&:to_i)

    bets = self.bets(user)
    if new_bets.keys.sort != bets.map(&:game_id).sort
      errors.add(:base, "Illegal game ids: #{new_bets.keys}")
      return false
    end
    unless new_bets.values.to_set.subset? Bet.answers.values.to_set
      errors.add(:base, "Illegal answer values: #{new_bets.values}")
      return false
    end

    bets.each do |b|
      b.answer = new_bets[b.game_id]
      b.save!
    end
  end

  def calendar
    RiCal.Calendar do |ical|
      ical.add_x_property 'X-WR-CALNAME', "#{self} round"

      games.each do |game|
        ical.event do |event|
          event.dtstart = game.start_time
          event.dtend = game.start_time + 90.minutes
          event.summary = "#{game.description} - #{game.team1} vs #{game.team2}"
        end
      end
    end.export
  end

  private

  def expiration_date_on_future
    errors.add(:expiration_date, 'must be in the future') unless open?
  end
end
