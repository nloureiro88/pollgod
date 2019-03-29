class Poll < ApplicationRecord

  # Relationships
  belongs_to :user
  belongs_to :category
  has_many :answers, dependent: :destroy

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
  QTYPES = ['open', 'private', 'sponsored']
  OTYPES = ['single choice', 'multiple choice'] # To increment in the future
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
  validate :val_options

  def like_hash
    like_hash = { love: 0, funny: 0, interest: 0 }
    active_answers = self.answers.where("status != 'deleted'")
    like_hash[:love] += active_answers.where(f_love: true).count
    like_hash[:funny] += active_answers.where(f_funny: true).count
    like_hash[:interest] += active_answers.where(f_interest: true).count
    like_hash
  end

  # def like_count
  #   like_hash[:love] + like_hash[:funny] + like_hash[:interest]
  # end

  def refresh_likes
    result_hash = like_hash
    self.t_love = result_hash[:love]
    self.t_funny = result_hash[:funny]
    self.t_interest = result_hash[:interest]
    self.t_likes = result_hash.values.sum
    self.save!
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
