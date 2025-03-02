require "securerandom"
require "base64"
require "openssl"

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable

  has_many :password_records, dependent: :destroy

  # Sharing all the password_records
  has_many :owned_shares, class_name: "SharedAccess", foreign_key: "owner_id", dependent: :destroy
  has_many :shared_with, through: :owned_shares, source: :collaborator

  has_many :received_shares, class_name: "SharedAccess", foreign_key: "collaborator_id", dependent: :destroy
  has_many :shared_owners, through: :received_shares, source: :owner

  # Sharing only specific password_records
  has_many :shared_password_records, class_name: "SharedPasswordRecord", foreign_key: "owner_id", dependent: :destroy
  has_many :shared_passwords, through: :shared_password_records, source: :password_record

  has_many :received_password_records, class_name: "SharedPasswordRecord", foreign_key: "collaborator_id", dependent: :destroy
  has_many :received_passwords, through: :received_password_records, source: :password_record


  validates_uniqueness_of :email, :display_name

  validates :email, :display_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :encrypted_password, length: { minimum: 8 }
end
