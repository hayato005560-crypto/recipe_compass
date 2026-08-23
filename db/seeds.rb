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

# 発表用レシピの投稿者
presentation_user = User.find_or_create_by!(email_address: "x@gmail") do |user|
  user.name = "x"
  user.password = "password"
  user.role = :general
  user.is_guest = false
  user.is_active = true
end

# 発表用レシピ
presentation_recipe = presentation_user.recipes.find_or_initialize_by(
  title: "鶏むね肉のトマトパスタ"
)

presentation_recipe.assign_attributes(
  body: "お好みでチーズやハーブを振ってどうぞ。",
  ingredients: <<~TEXT.strip,
    鶏むね肉 … 100〜120g
    パスタ … 80〜90g
    にんにく … 1片
    玉ねぎ … 1/4個
    プチトマト … 4個
    オリーブオイル … 小さじ2
    塩・こしょう … 適量
    ブロッコリー … 適量
    乾燥バジル or ハーブ … お好みで
    パルメザンチーズ … お好みで
  TEXT
  steps: <<~TEXT.strip,
    鶏むね肉は細めに切り塩こしょうする。プチトマトは半分に、玉ねぎ・にんにくは薄切り／みじん切りにする。
    フライパンでにんにくを炒め、鶏むね肉を焼いて取り出す。
    同じフライパンで玉ねぎ→プチトマト→ブロッコリーを炒め、味を調える。
    茹でたパスタと鶏むね肉を戻し入れ、全体をよく絡めて完成。
  TEXT
  cooking_time: 20
)

# 発表用画像
image_path = Rails.root.join(
  "db",
  "seed_images",
  "chicken_tomato_pasta.jpg"
)

unless presentation_recipe.image.attached?
  presentation_recipe.image.attach(
    io: File.open(image_path),
    filename: "chicken_tomato_pasta.jpg"
  )
end

# 画像を含めた状態で保存
presentation_recipe.save!

# 4つの目的すべてを設定
presentation_recipe.purposes =
  Purpose.where(name: purpose_names)