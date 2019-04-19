class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Photo
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
    user_tickets[:followers] += Friend.where("follow_user_id = ? AND status = 'active'", self.id).count * 9
    user_tickets
  end

  def top_polls
    Poll.where("status != 'deleted' AND user_id = ?", self.id).order(:points).take(5)
  end

  def evolution(month, year, type)
    c_month = month.to_i + 1
    c_year = year.to_i
    evodata = {}

    12.times do
      if c_month == 1
        c_month = 12
        c_year -= 1
      else
        c_month -= 1
      end

      c_date = Date.new(c_year, c_month, 1)

      if type == 'poll'
        evodata[c_date.strftime("%b.%y")] = Poll.where('user_id = ? AND status != ? AND created_at >= ? AND created_at < ?',
                                                 self.id, 'deleted', c_date, c_date + 1.month).count
      else
        evodata[c_date.strftime("%b.%y")] = Answer.where('user_id = ? AND status != ? AND created_at >= ? AND created_at < ?',
                                                   self.id, 'deleted', c_date, c_date + 1.month).count
      end
    end
    data = evodata.to_a.reverse.to_h
  end

  def cat_stat(type)
    data_hash = Hash.new(0)

    Category.all.each do |cat|
      if type == "poll"
        data_hash[cat.id] += Poll.where('user_id = ? AND status != ? AND category_id = ?', self.id, 'deleted', cat.id).count
      else
        data_hash[cat.id] += Answer.where('user_id = ? AND status != ?', self.id, 'deleted').select { |ans| Poll.find(ans.poll_id).category_id == cat.id }.count
      end
    end

    data_hash
  end
end
