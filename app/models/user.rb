class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable

  enum :role, { admin: 0, manager: 1, staff: 2 }, default: :staff

  has_many :time_entries, dependent: :destroy
  has_many :sales_forecasts, dependent: :destroy

  validates :hourly_rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
