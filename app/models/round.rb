require 'csv'

class Round < ApplicationRecord
  belongs_to :tournament
  has_many :games, -> { order 'created_at ASC' }, inverse_of: :round, dependent: :destroy
  has_many :multi_choices, -> { order 'created_at ASC' }, inverse_of: :round, dependent: :destroy
  validates_associated :tournament
  validates :name, length: { in: 2..100 }
  validates :name, :expiration_date, presence: true
  validate :expiration_date_on_future, on: :create
  validates_uniqueness_of :name, scope: [:tournament]
  accepts_nested_attributes_for :games, allow_destroy: true
  accepts_nested_attributes_for :multi_choices, allow_destroy: true

  def to_s
    name
  end

  def open?
    expiration_date && (expiration_date > DateTime.now)
  end

  def closed?
    not open?
  end

  def bets(user)
    games.map do |game|
      Bet.find_or_create_by(game_id: game.id, user_id: user.id)
    end
  end

  def mc_bets(user)
    multi_choices.map do |mc|
      MultiChoiceBet.find_or_create_by(multi_choice_id: mc.id, user_id: user.id)
    end
  end

  def users_who_bet
    s = Set.new
    games.each do |game|
      game.bets.each do |bet|
        s.add(bet.user_id)
      end
    end
    multi_choices.each do |mc|
      mc.multi_choice_bets.each do |bet|
        s.add(bet.user_id)
      end
    end
    s.map{ |user_id| User.find(user_id) }
  end

  def all_users_bets_table
    header = ["User"]
    result = ["Result"]
    all_games = (games + multi_choices)
    h = Hash.new { |h,k| h[k] = Array.new(all_games.length) }
    all_games.each_with_index do |game, col_index|
      header.append(game.short_description)
      result.append(game.result_name)
      game.bets.each do |bet|
        h[bet.user_id][col_index] = bet.answer_name
      end
    end
    h.transform_keys{ |user_id| User.find(user_id) }
    values = h.collect do |user_id, row|
      [User.find(user_id).name] + row
    end

    [header, result] + values
  end

  def all_users_bets_table_csv
    CSV.generate(headers: true) do |csv|
      all_users_bets_table.each do |row|
        csv << row
      end
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

  def update_multi_choice_bets(new_multi_choice_bets, user)
    unless open?
      errors.add(:base, "Round already closed.")
      return false
    end
    new_multi_choice_bets.transform_keys!(&:to_i)
    new_multi_choice_bets.transform_values!(&:to_s)

    multi_choice_bets = self.mc_bets(user)
    if new_multi_choice_bets.keys.sort != multi_choice_bets.map(&:multi_choice_id).sort
      errors.add(:base, "Illegal multi choice IDs: #{new_multi_choice_bets.keys}")
      return false
    end

    multi_choice_bets.each do |b|
      b.answer = new_multi_choice_bets[b.multi_choice_id]
      b.save!
    end
  end

  def calendar
    RiCal.Calendar do |ical|
      ical.add_x_property 'X-WR-CALNAME', "#{self} round"

      games.each do |game|
        ical.event do |event|
          event.dtstart = game.start_time.to_datetime
          event.dtend = (game.start_time + 90.minutes).to_datetime
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
