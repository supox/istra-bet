class MultiChoiceBet < ApplicationRecord
  belongs_to :multi_choice
  belongs_to :user

  validates_associated :multi_choice, :user

  validates :answer, presence: true
  validates_uniqueness_of :multi_choice, scope: :user
  validate :answer_part_of_options

  def answer_name
    if answer.nil?
      "-"
    else
      answer
    end
  end

  def points
    if answer.to_s == multi_choice.result.to_s
      multi_choice.bet_points
    else
      0
    end
  end

  def answer_part_of_options
    unless answer.nil? or multi_choice.nil?
      errors.add(:answer, 'must be part of options') unless multi_choice.options.include? answer
    end

  end
end
