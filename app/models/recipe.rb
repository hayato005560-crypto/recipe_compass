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
    scores = ratings.filter_map(&:score)
    return 0 if scores.empty?

    (scores.sum.to_f / scores.size).round(1)
  end

  def rating_count
    ratings.count { |rating| rating.score.present? }
  end

  scope :by_purpose, ->(purpose_id) {
    joins(:purposes).where(purposes: { id: purpose_id })
  }

  scope :newest, -> { order(created_at: :desc) }
  scope :oldest, -> { order(created_at: :asc) }

  scope :high_rating, -> {
    left_joins(:ratings)
      .group("recipes.id")
      .order("AVG(ratings.score) DESC")
  }

  scope :search_by_keyword, ->(keyword, target) {
    case target
    when "title"
      where("title LIKE ?", "%#{keyword}%")
    when "body"
      where("body LIKE ?", "%#{keyword}%")
    when "ingredients"
      where("ingredients LIKE ?", "%#{keyword}%")
    when "steps"
      where("steps LIKE ?", "%#{keyword}%")
    when "all"
      where(
        "title LIKE ? OR body LIKE ? OR ingredients LIKE ? OR steps LIKE ?",
        "%#{keyword}%", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%"
      )
    else
      all
    end
  }

  scope :search_by_food_labels, ->(food_labels) {
    recipes = none

    food_labels.each do |label|
      recipes = recipes.or(
        where("ingredients LIKE ?", "%#{label}%")
      )
    end

    recipes
  }

  private

  def image_must_be_attached
    errors.add(:image, :blank) unless image.attached?
  end



end
