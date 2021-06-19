class MultiChoice < ApplicationRecord
  class OptionSerializer
    def self.load(value)
      YAML.load(value || "[]")
    end

    def self.dump(value)
      if value.is_a? String
        value = YAML.load(value)
      end

      YAML.dump(value)
    end
  end

  belongs_to :round, inverse_of: :multi_choices
  has_many :multi_choice_bets, :dependent => :destroy

  validates_associated :round
  serialize :options, OptionSerializer

  validates :description, length: { in: 2..40 }
  validates :options, length: { in: 2..200 }
  validate :not_the_same_team, :result_part_of_options, :options_elements
  validates :description, :options, :bet_points, presence: true
  validates :bet_points, numericality: { greater_than: 0 }

  def options_str
    options.join(", ")
  end

  def not_the_same_team
    unless options.nil?
      errors.add(:options, 'must be unique') if options != options.uniq
    end
  end

  def result_part_of_options
    unless result.nil? or result.empty? or options.nil?
      errors.add(:result, 'must be part of options') unless options.include? result
    end
  end

  def options_elements
    unless options.nil?
      options.each { |name| errors.add(:options, 'Name #{name} too is not valid') if name.nil? or name.length <=2 or name.length > 200 }
    end
  end
end
