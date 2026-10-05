class RecipesController < ApplicationController
  before_action :reject_guest, only: %i[new create edit update destroy]

  # AI画像検索で許可する画像形式・最大サイズ
  ALLOWED_IMAGE_TYPES = ["image/jpeg", "image/png"].freeze
  MAX_IMAGE_SIZE = 5.megabytes

  def index
    keyword = params[:keyword]
    target = params[:target]
    @purposes = Purpose.all
    purpose_id = params[:purpose_id]
    @recipes = Recipe.includes(:ratings, :purposes, :user).with_attached_image
    sort = params[:sort]

    # AI画像検索の結果を使ったレシピ検索
    @food_labels = params[:food_labels]

    if @food_labels.present?
      @recipes = @recipes.search_by_food_labels(@food_labels)
    end

    # キーワード・検索対象による絞り込み
    if keyword.present?
      @recipes = @recipes.search_by_keyword(keyword, target)
    end

    # Purposeによる絞り込み
    if purpose_id.present?
      @recipes = @recipes.by_purpose(purpose_id)
    end

    # 表示順の変更
    case sort
    when "newest"
      @recipes = @recipes.newest
    when "oldest"
      @recipes = @recipes.oldest
    when "high_rating"
      @recipes = @recipes.high_rating
    else
      @recipes = @recipes.oldest
    end

    @recipes = @recipes.page(params[:page]).per(10)
  end

  def show
    @recipe = Recipe.find(params[:id])
    @comments = @recipe.comments

    # ゲスト・投稿者本人以外は評価可能
    if Current.user.present? &&
       !Current.user.is_guest? &&
       Current.user != @recipe.user

      @rating = @recipe.ratings.find_or_initialize_by(user: Current.user)
    end
  end

  def new
    @recipe = Recipe.new
  end

  def create
    @recipe = Current.user.recipes.new(recipe_params)

    if @recipe.save
      redirect_to @recipe, notice: "レシピを投稿しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @recipe = Current.user.recipes.find(params[:id])
  end

  def update
    @recipe = Current.user.recipes.find(params[:id])

    if @recipe.update(recipe_params)
      redirect_to @recipe, notice: "レシピを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipe = Current.user.recipes.find(params[:id])
    @recipe.destroy
    redirect_to recipes_path, notice: "レシピを削除しました。"
  end

  # 画像から食材候補を取得してレシピを検索
  def image_search
    image = params[:image]

    # 画像未選択
    unless image.present?
      redirect_to recipes_path, alert: "画像を選択してください。"
      return
    end

    # 画像形式チェック
    unless ALLOWED_IMAGE_TYPES.include?(image.content_type)
      redirect_to recipes_path, alert: "JPEGまたはPNG形式の画像を選択してください。"
      return
    end

    # ファイルサイズチェック
    if image.size > MAX_IMAGE_SIZE
      redirect_to recipes_path, alert: "画像サイズは5MB以下にしてください。"
      return
    end

    # Vision API・Translation APIを使って検索用ラベルを取得
    begin
      food_labels = VisionService.new.analyze(image)
    rescue StandardError => e
      Rails.logger.error("Image search failed: #{e.class}")
      redirect_to recipes_path, alert: "画像検索中にエラーが発生しました。時間をおいて再度お試しください。"
      return
    end

    # 検索に使える食材が取得できなかった場合
    if food_labels.blank?
      redirect_to recipes_path, alert: "画像から食材を認識できませんでした。別の画像をお試しください。"
      return
    end

    redirect_to recipes_path(food_labels: food_labels)
  end

  private

  def recipe_params
    params.require(:recipe).permit(
      :title,
      :body,
      :cooking_time,
      :ingredients,
      :steps,
      :image,
      purpose_ids: []
    )
  end
end
