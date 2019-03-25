class Filter < ApplicationRecord

  # Relationships
  belongs_to :user
  belongs_to :category

  # Validations
  validates :user_id, presence: true, allow_blank: false
  validates :category_id, presence: true, allow_blank: false, uniqueness: { scope: :user_id }
  validates :active, inclusion: { in: [true, false] }
end
