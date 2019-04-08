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
end
