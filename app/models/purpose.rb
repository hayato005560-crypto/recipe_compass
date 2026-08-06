class Purpose < ApplicationRecord
  has_many :recipe_purposes, dependent: :destroy
  has_many :recipes, through: :recipe_purposes

  validates :name, presence: true, uniqueness: true
end
