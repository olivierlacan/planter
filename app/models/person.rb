class Person < ApplicationRecord
  has_many :plants
  validates :email, presence: true

  def to_s
    name
  end
end
