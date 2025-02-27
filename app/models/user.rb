require "securerandom"
require "base64"
require "openssl"

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :password_records, dependent: :destroy

  has_many :owned_shares, class_name: "SharedAccess", foreign_key: "owner_id", dependent: :destroy
  has_many :shared_with, through: :owned_shares, source: :collaborator

  has_many :received_shares, class_name: "SharedAccess", foreign_key: "collaborator_id", dependent: :destroy
  has_many :shared_owners, through: :received_shares, source: :owner

  validates_uniqueness_of :email, :display_name

  validates :email, :display_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :display_name, length: { minimum: 3, maximum: 20 }
  validates :encrypted_password, length: { minimum: 8 }
end
