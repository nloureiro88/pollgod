class Poll < ApplicationRecord

  # Relationships
  belongs_to :user
  belongs_to :category
  has_many :answers, dependent: :destroy

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

  def like_count
    counter = 0
    answers = self.answers
    answers.each do |ans|
      counter += 1 if ans.f_love?
      counter += 1 if ans.f_funny?
      counter += 1 if ans.f_interest?
    end
    counter
  end


  def like_hash
    like_hash = { love: 0, funny: 0, interest: 0 }
    answers = self.answers
    answers.each do |ans|
      like_hash[:love] += 1 if ans.f_love?
      like_hash[:funny] += 1 if ans.f_funny?
      like_hash[:interest] += 1 if ans.f_interest?
    end
    like_hash
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
