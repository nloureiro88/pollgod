class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # # Photo
  mount_uploader :photo, PhotoUploader

  # Relationships
  has_many :polls
  has_many :answers
  has_many :filters

  # Lists
  SUBSCRIPTIONS = ['free', 'premium', 'pro']

  # Validations
  validates :first_name, presence: true, allow_blank: false
  validates :last_name, presence: true, allow_blank: false
  validates :birthdate, presence: true, allow_blank: false
  validates :gender, presence: true, inclusion: { in: ['Male', 'Female'] }
  validates :location, presence: true, allow_blank: false
  validates :profession, presence: true, allow_blank: false
  validates :subscription, presence: true, inclusion: { in: SUBSCRIPTIONS }

  def age
    now = Time.now.utc.to_date
    now.year - self.birthdate.year - ((now.month > self.birthdate.month || (now.month == self.birthdate.month && now.day >= self.birthdate.day)) ? 0 : 1)
  end

  def stats
    user_stats = Hash.new(0)
    user_stats[:followers] = Friend.where(status: 'active', follow_user_id: self.id).count
    user_stats[:polls] = Poll.where("status != 'deleted' AND user_id = ?", self.id).count
    user_stats[:answers] = Answer.where("status != 'deleted' AND user_id = ?", self.id).count
    user_stats[:tickets] = self.tickets.values.sum
    user_stats
  end

  def tickets
    user_tickets = Hash.new(0)
    user_polls = Poll.where("user_id = ? AND status != 'deleted'", self.id)
    user_polls.each do |poll|
      user_tickets[:polls_answered] += poll.count_answers * 3
      user_tickets[:polls_liked] += poll.like_hash.values.sum * 3
    end
    user_tickets[:answers] += Answer.where("user_id = ? AND status != 'deleted'", self.id).pluck(:points).sum
    user_tickets[:followers] += Friend.where("follow_user_id = ? AND status = 'active'", self.id).count * 5
    user_tickets
  end
end
