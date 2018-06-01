class User < ApplicationRecord
  has_many :bets, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable #, :confirmable

  def to_s
    self.email
  end

  def score
    bets.sum(&:points)
  end
end
