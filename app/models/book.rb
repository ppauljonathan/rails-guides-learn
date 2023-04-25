class Book < ApplicationRecord
  validates :name, length: { minimum: 3 }, uniqueness: true
end
