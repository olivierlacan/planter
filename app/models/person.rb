class Person < ApplicationRecord
  validates :email, presence: true

  def to_s
    name
  end
end
