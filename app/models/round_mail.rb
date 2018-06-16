class RoundMail
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :subject, :body

  validates_presence_of :subject, :body
  validates_length_of :body, minimum: 10, maximum: 500
  validates_length_of :subject, minimum: 10, maximum: 120

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end
