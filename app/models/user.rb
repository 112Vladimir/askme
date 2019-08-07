require 'openssl'

class User < ApplicationRecord
  # параметры работы модуля шифрования паролей
  ITERATIONS = 2000
  DIGEST = OpenSSL::Digest::SHA256.new

  has_many :questions

  validates :username, length: { maximum: 40 }
  validates :username, format: { with: /\A[a-zA-Z]|[_]?\d+\z/ }

  validates :email, :username, presence: true
  validates :email, :username, uniqueness: true

  attr_accessor :password

  validates_presence_of :password, on: :create
  validates_confirmation_of :password

  before_save :encrypt_password

  def encrypt_password
    if self.password.present?
      #создаём т. н. "соль" - рандоманя строка усложняющая задачу хакерам
      self.password_salt = User.hash_to_string(OpenSSL::Random.random_bytes(16))

      # создаём хэш пароля - длинная уникальная строка, из которой невозможно восстанвоить исходящий пароль
      self.password_hash = User.hash_to_string(
                                   OpenSSL::PKCS5.pbkdf2_hmac(self.password, self.password_salt, ITERATIONS, DIGEST.length, DIGEST)
      )
    end
  end


    # служебный метод, преобразующий бинарную строку в 16-ричный формат, для удобства хранения
    def self.hash_to_string(password_hash)
      password_hash.unpack('H*')[0]
    end

  def self.authenticate(email, password)
    user = find_by(email: email) # сперва находим кандидата по email

    # ОБРАТИТЬ ВНИМЕНИЕ: сравнивается password_hash, а оригинальный пароль так никогда и не сохраняется нигде!
    if user.present? && user.password_hash == User.hash_to_string(OpenSSL::PKCS5.pbkdf2_hmac(password, user.password_salt, ITERATIONS, DIGEST.length, DIGEST))
      user
    else
      nil
    end
  end
end
