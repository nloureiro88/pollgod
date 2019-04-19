class Poll < ApplicationRecord

  # Relationships
  belongs_to :user
  belongs_to :category
  has_many :answers, dependent: :destroy
  has_many :active_users, class_name: "User", foreign_key: :active_user_id
  has_many :follow_users, class_name: "User", foreign_key: :follow_user_id

  # Search
  include PgSearch
  pg_search_scope :poll_search,
    against: [ :question, :tags ],
    associated_against: {
      user: [ :first_name, :last_name ],
      category: [ :name ]
    },
    using: {
      tsearch: { prefix: true }
    }

  # Lists
  QTYPES = ['open', 'closed', 'sponsored']
  OTYPES = ['SCP', 'MCP'] # To increment in the future
  STATUS = ['active', 'inactive', 'deleted']

  # Validations
  validates :user_id, presence: true, allow_blank: false
  validates :category_id, presence: true, allow_blank: false
  validates :points, presence: true, numericality: { only_integer: true, greater_then: 0 }
  validates :qtype, presence: true, inclusion: { in: QTYPES }
  validates :optype, presence: true, inclusion: { in: OTYPES }
  validates :question, presence: true, length: { maximum: 80 } # Consider uniqueness: true for real data
  validates :deadline, presence: true, allow_blank: false
  validates :status, presence: true, inclusion: { in: STATUS }
  validates :tags, length: { maximum: 45 }
  validate :val_options

  def like_hash
    like_hash = { love: 0, funny: 0, interest: 0 }
    active_answers = self.answers.where("status != 'deleted'")
    like_hash[:love] += active_answers.where(f_love: true).count
    like_hash[:funny] += active_answers.where(f_funny: true).count
    like_hash[:interest] += active_answers.where(f_interest: true).count
    like_hash
  end

  def refresh_likes
    result_hash = like_hash
    self.t_love = result_hash[:love]
    self.t_funny = result_hash[:funny]
    self.t_interest = result_hash[:interest]
    self.t_likes = result_hash.values.sum
    self.save!
  end

  def count_answers
    self.answers.where("status != 'deleted'").count
  end

  def answer(user)
    self.answers.where("status != 'deleted' AND user_id = ?", user.id)
  end

  def answered?(user)
    self.answer(user).count.positive?
  end

  def results
    result_hash = Hash.new(0)
    self.options.each_with_index do |_opt, index|
      result_hash[index] += Answer.where("status != 'deleted' AND poll_id = ? AND answer = ?", self.id, index.to_s).count
    end
    result_hash
  end

  def gender_stats
    result_hash = {}
    result_hash[:men] = []
    result_hash[:women] = []

    self.options.each_with_index do |_opt, index|
      answers = Answer.where("status != 'deleted' AND poll_id = ? AND answer = ?", self.id, index.to_s)
      result_hash[:men] << answers.select { |a| a.user.gender == 'Male' }.count
      result_hash[:women] << answers.select { |a| a.user.gender == 'Female' }.count
    end
    result_hash
  end

  def age_stats
    result_hash = Hash.new { |h, k| h[k] = [] }

    self.options.each_with_index do |_opt, index|
      answers = Answer.where("status != 'deleted' AND poll_id = ? AND answer = ?", self.id, index.to_s)
      result_hash[:m25] << answers.select { |a| a.user.age < 25 }.count
      result_hash[:m35] << answers.select { |a| a.user.age >= 25 && a.user.age < 35 }.count
      result_hash[:m45] << answers.select { |a| a.user.age >= 35 && a.user.age < 45 }.count
      result_hash[:m55] << answers.select { |a| a.user.age >= 45 && a.user.age < 55 }.count
      result_hash[:m55] << answers.select { |a| a.user.age >= 55 }.count
    end
    result_hash
  end

  def top_profs
    answers = Answer.where(poll: self, status: 'active').order(:created_at)
    prof_hash = Hash.new(0)

    answers.each do |ans|
      user_prof = ans.user.profession
      prof_hash[user_prof] += 1
    end

    prof_hash.sort_by {|k, v| [-v, k] }.take(8)
  end

  def prof_stats
    profs = top_profs
    result_hash = Hash.new { |h, k| h[k] = [] }

    profs.each do |prof, _value|
      self.options.each_with_index do |_opt, index|
        result_hash[index] << User.joins('INNER JOIN answers ON users.id = answers.user_id')
                                  .where('profession = ? AND answers.poll_id = ? AND answers.status = ? AND answers.answer = ?',
                                          prof, self, 'active', index.to_s).count
      end
    end

    result_hash
  end

  def top_countries
    answers = Answer.where(poll: self, status: 'active').order(:created_at)
    country_hash = Hash.new(0)

    answers.each do |ans|
      user_country = ans.user.location
      country_hash[user_country] += 1
    end

    country_hash.sort_by {|k, v| [-v, k] }.take(8)
  end

  def country_stats
    countries = top_countries
    result_hash = Hash.new { |h, k| h[k] = [] }

    countries.each do |country, _value|
      self.options.each_with_index do |_opt, index|
        result_hash[index] << User.joins('INNER JOIN answers ON users.id = answers.user_id')
                                  .where('location = ? AND answers.poll_id = ? AND answers.status = ? AND answers.answer = ?',
                                          country, self, 'active', index.to_s).count
      end
    end

    result_hash
  end

  def answers_evo
    result_hash = Hash.new(0)
    answers = Answer.where(poll: self, status: 'active').order(:created_at)

    start_date = answers.size.zero? ? Date.parse(self.created_at.to_s) : Date.parse(answers.first.created_at.to_s)
    end_date = answers.size.zero? ? Date.parse(self.deadline.to_s) : Date.parse(answers.last.created_at.to_s)
    start_date -= 1 if start_date == end_date
    date = start_date

    answer_hash = Hash.new(0)
    answer_date = answers.map { |ans| Date.parse(ans.created_at.to_s) }
    answer_input = answer_date.each { |ad| answer_hash[ad.strftime("%d.%m.%y")] += 1 }
    cumulative = 0

    until date == end_date + 1
      date_st = date.strftime("%d.%m.%y")
      cumulative += answer_hash[date_st]
      result_hash["   #{date_st}"] = cumulative
      date += 1
    end

    result_hash
  end

  def like_evo
    answers = Answer.where(poll: self, status: 'active').order(:created_at)

    start_date = answers.size.zero? ? Date.parse(self.created_at.to_s) : Date.parse(answers.first.created_at.to_s)
    end_date = answers.size.zero? ? Date.parse(self.deadline.to_s) : Date.parse(answers.last.created_at.to_s)
    start_date -= 1 if start_date == end_date
    date = start_date

    a_dates = []
    a_loved = []
    a_funny = []
    a_interest = []

    until date == end_date + 1
      a_dates << "   #{date.strftime("%d.%m.%y")}"
      a_loved << { x: " #{date.strftime('%d.%m.%y')}",
                   y: "#{ Answer.where("f_love = true AND status = 'active' AND poll_id = ? AND created_at <= ?", self.id, date + 1).count + 0.2}" }
      a_funny << { x: " #{date.strftime('%d.%m.%y')}",
                   y: "#{ Answer.where("f_funny = true AND status = 'active' AND poll_id = ? AND created_at <= ?", self.id, date + 1).count + 0.1}" }
      a_interest << { x: " #{date.strftime('%d.%m.%y')}",
                      y: "#{ Answer.where("f_interest = true AND status = 'active' AND poll_id = ? AND created_at <= ?", self.id, date + 1).count}" }

      date += 1
    end

    result_hash = {}
    result_hash[:dates] = a_dates
    result_hash[:loved] = a_loved
    result_hash[:funny] = a_funny
    result_hash[:interesting] = a_interest
    result_hash
  end

  private

  def val_options
    if options.nil? || options.class != Array
      errors.add("No answer options for the question.")
    elsif options.size < 2 || options.size > 5
      errors.add("Invalid number options for the question.")
    end
  end
end
