require "base64"
require "net/http"
require "uri"
require "json"

class VisionService
  API_URL = "https://vision.googleapis.com/v1/images:annotate"
  TRANSLATION_API_URL = "https://translation.googleapis.com/language/translate/v2"

  # レシピ検索に不要なVision APIのラベル
  IGNORE_LABELS = [
    "Food",
    "Ingredient",
    "Tableware",
    "Dishware",
    "Plate",
    "Al dente",
    "Vegetable",
    "Produce"
  ].freeze

  # 翻訳結果とレシピ登録時の表記ゆれを補完
  FOOD_SYNONYMS = {
    "チキン" => ["鶏肉"],
    "鶏肉" => ["チキン"],
    "ポテト" => ["じゃがいも"],
    "じゃがいも" => ["ポテト"],
    "オニオン" => ["玉ねぎ"],
    "玉ねぎ" => ["オニオン"]
  }.freeze

  def initialize
    @api_key = ENV["GOOGLE_API_KEY"]
  end

  # 画像をAPIへ送信できるBase64形式へ変換
  def encode_image(image)
    Base64.strict_encode64(image.read)
  end

  # Vision APIで画像を解析し、検索用の日本語ラベルを作成
  def analyze(image)
    encoded_image = encode_image(image)

    request_body = {
      requests: [
        {
          image: {
            content: encoded_image
          },
          features: [
            {
              type: "LABEL_DETECTION"
            }
          ]
        }
      ]
    }

    uri = URI("#{API_URL}?key=#{@api_key}")

    response = Net::HTTP.post(
      uri,
      request_body.to_json,
      { "Content-Type" => "application/json" }
    )

    result = JSON.parse(response.body)

    # Vision APIの結果からラベル名を取得
    labels = extract_labels(result)

    # 検索に不要なラベルを除外
    filtered_labels = filter_labels(labels)

    # 英語ラベルを日本語へ翻訳
    translated_labels = translate_labels(filtered_labels)

    # 表記ゆれを追加して検索用ラベルとして返す
    expand_synonyms(translated_labels)
  end

  # Vision APIのレスポンスからラベル名だけを取得
  def extract_labels(result)
    annotations = result["responses"][0]["labelAnnotations"]

    annotations.map do |annotation|
      annotation["description"]
    end
  end

  # 検索に不要なラベルを除外
  def filter_labels(labels)
    labels.reject do |label|
      IGNORE_LABELS.include?(label)
    end
  end

  # Translation APIで英語ラベルを日本語へ翻訳
  def translate_labels(labels)
    uri = URI(TRANSLATION_API_URL)
    uri.query = URI.encode_www_form(key: @api_key)

    request_body = {
      q: labels,
      source: "en",
      target: "ja",
      format: "text"
    }

    response = Net::HTTP.post(
      uri,
      request_body.to_json,
      { "Content-Type" => "application/json" }
    )

    body = response.body.force_encoding("UTF-8")
    result = JSON.parse(body)

    result["data"]["translations"].map do |translation|
      translation["translatedText"]
    end
  end

  # 同じ意味の表記を検索候補へ追加し、重複を削除
  def expand_synonyms(labels)
    labels.flat_map do |label|
      [label] + FOOD_SYNONYMS.fetch(label, [])
    end.uniq
  end
end
