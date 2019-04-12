class Friend < ApplicationRecord
  belongs_to :active_user, class_name: "User"
  belongs_to :follow_user, class_name: "User"

  validates :follow_user_id, uniqueness: { scope: :active_user_id }

  def info
    self.follow_user_id
  end
end
