class User < ApplicationRecord
  has_many :bets, dependent: :destroy

  validates :name, length: { in: 2..100 }
  validates_uniqueness_of :name
  validates_format_of :name, with: /^[a-zA-Z0-9_\. ]*$/, :multiline => true
  after_create :skip_conf!
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  scope :confirmed, -> { where("confirmed_at IS NOT NULL") }
  scope :subscribed, -> { where("confirmed_at IS NOT NULL AND subscription") }

  def to_s
    name
  end

  def score
    bets.sum(&:points)
  end

  private

  def skip_conf!
    confirm if Rails.env.development? || Rails.env.test?
  end
end
