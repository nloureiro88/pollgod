class Category < ApplicationRecord

  # Relationships
  has_many :filters
  has_many :polls
  has_many :answers, through: :polls
  has_many :users, through: :filters

  # Validations
  validates :name, presence: true, allow_blank: false, uniqueness: true
  validates :color, presence: true, allow_blank: false, uniqueness: true
  validates :icon, presence: true, allow_blank: false, uniqueness: true
end
