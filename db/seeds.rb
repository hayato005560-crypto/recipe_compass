# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
purpose_names = ["ダイエット", "筋肉増量", "時短", "節約"]

purpose_names.each do |name|
  Purpose.find_or_create_by!(name: name)
end

test_user = User.find_or_create_by!(email_address: "test@gmail.com") do |user|
  user.name = "test"
  user.password = "test"
end

test_recipe = test_user.recipes.find_or_create_by!(title: "テストタイトル") do |recipe|
  recipe.steps = "テスト工程"
  recipe.ingredients = "テスト材料"
  recipe.cooking_time = 1
end

test_purpose = Purpose.find_by!(name: "ダイエット")
test_recipe.purposes << test_purpose unless test_recipe.purposes.include?(test_purpose)