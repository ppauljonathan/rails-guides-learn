class User < ApplicationRecord
  validates :name, presence: true
end

# save => returns false if validation fails
# save! => throws error if validation fails
