class Recipe < ApplicationRecord
  belongs_to :user
  has_many :recipe_purposes, dependent: :destroy
  has_many :purposes, through: :recipe_purposes
  has_many :comments, dependent: :destroy
  has_one_attached :image

  validates :title, :ingredients, :steps, :cooking_time, presence: true
  validates :cooking_time, numericality: { only_integer: true, greater_than: 0 }

end
