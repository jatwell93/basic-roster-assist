class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable

  enum :role, { admin: 0, manager: 1, staff: 2 }, default: :staff

  has_many :time_entries, dependent: :destroy
  has_many :sales_forecasts, dependent: :destroy

  validates :hourly_rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # PIN verification for clock-in/out functionality
  def valid_pin?(pin)
    return false if encrypted_pin.blank? || encrypted_pin_iv.blank?

    begin
      decipher = OpenSSL::Cipher.new("aes-256-cbc")
      decipher.decrypt
      decipher.key = Rails.application.secret_key_base[0..31] # Use first 32 bytes for AES-256
      decipher.iv = Base64.decode64(encrypted_pin_iv)

      decrypted_pin = decipher.update(Base64.decode64(encrypted_pin)) + decipher.final
      decrypted_pin == pin.to_s
    rescue OpenSSL::Cipher::CipherError, ArgumentError
      false
    end
  end
end
