class User < ApplicationRecord
  has_many :user_stocks
  has_many :stocks, through: :user_stocks

  validates :name, :ticker, presence: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
