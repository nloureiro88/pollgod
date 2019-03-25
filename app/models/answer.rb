class Answer < ApplicationRecord
  belongs_to :user
  belongs_to :poll

  # Lists
  STATUS = ['active', 'inactive', 'deleted']

  # Validations
  validates :user_id, presence: true, allow_blank: false
  validates :poll_id, presence: true, allow_blank: false, uniqueness: { scope: :user_id }
  validates :points, presence: true, numericality: { only_integer: true, greater_then: 0 }
  validates :f_love, inclusion: { in: [true, false] }
  validates :f_funny, inclusion: { in: [true, false] }
  validates :f_interest, inclusion: { in: [true, false] }
  validates :status, presence: true, inclusion: { in: STATUS }
  validate :val_answer

  private

  def val_answer
    error_message = ""
    answer.split(",").each do |option|
      target_poll = Poll.find(poll_id)
      error_message = "Invalid answer option(s) for this poll." unless (option.to_i >= 0 && option.to_i < target_poll.options.size)
    end
    errors.add(error_message) unless error_message.empty?
  end
end
