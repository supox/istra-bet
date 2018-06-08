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

  def to_s
    self.name
  end

  def score
    bets.sum(&:points)
  end

private

  def skip_conf!
    self.confirm if Rails.env.development?
  end

end
