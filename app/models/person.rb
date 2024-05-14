class Person < ApplicationRecord
  validates :email, presence: true
end
