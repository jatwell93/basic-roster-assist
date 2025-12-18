class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable

  enum :role, { admin: 0, manager: 1, staff: 2 }, default: :staff

  has_many :time_entries, dependent: :destroy
end
