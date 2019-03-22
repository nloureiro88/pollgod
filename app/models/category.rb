class Category < ApplicationRecord

  # Relationships
  has_many :filters
  has_many :polls
  has_many :answers, through: :polls
  has_many :users, through: :filters

end
