class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  validates :score, presence: true, inclusion: { in: 1..5}

  validates :user_id, uniqueness: { scope: :recipe_id }
end
