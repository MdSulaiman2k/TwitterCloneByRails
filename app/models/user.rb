class User < ApplicationRecord
  has_many :posts
  require "securerandom"

  before_validation :set_uuid, on: :create

  has_secure_password
  validates :name, length: { minimum: 2 }, presence: true
  validates :email, presence: true, :uniqueness => { :case_sensitive => false }

  def set_uuid
    self.userToken = SecureRandom.uuid
  end
end
