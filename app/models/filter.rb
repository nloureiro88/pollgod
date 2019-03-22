class Filter < ApplicationRecord

  # Relationships
  belongs_to :user
  belongs_to :category

end
