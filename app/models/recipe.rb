class Recipe < ApplicationRecord
  belongs_to :user
  has_many :recipe_purposes, dependent: :destroy
  has_many :purposes, through: :recipe_purposes
  has_many :comments, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_one_attached :image

  validates :title, :ingredients, :steps, :cooking_time, presence: true
  validates :cooking_time, numericality: { only_integer: true, greater_than: 0 }

  validate :image_must_be_attached

  def average_rating
    return 0 if ratings.empty?

    ratings.average(:score).to_f.round(1)
  end

  def rating_count
    ratings.count
  end

  private

  def image_must_be_attached
    errors.add(:image, :blank) unless image.attached?
  end



end
