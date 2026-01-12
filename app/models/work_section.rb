class WorkSection < ApplicationRecord
  belongs_to :user
  has_many :base_shifts, dependent: :nullify
  
  validates :name, presence: true, uniqueness: { scope: :user_id }
end
