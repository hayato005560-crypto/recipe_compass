require "base64"
require "net/http"
require "uri"
require "json"

class VisionService
  API_URL = "https://vision.googleapis.com/v1/images:annotate"
  TRANSLATION_API_URL = "https://translation.googleapis.com/language/translate/v2"

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

  def encode_image(image)
    Base64.strict_encode64(image.read)
  end

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

    labels = extract_labels(result)

    filtered_labels = filter_labels(labels)

    translated_labels = translate_labels(filtered_labels)

    translate_labels(filtered_labels)
  end

  def extract_labels(result)
    annotations = result["responses"][0]["labelAnnotations"]

    annotations.map do |annotation|
      annotation["description"]
    end
  end

  def filter_labels(labels)
    labels.reject do |label|
      IGNORE_LABELS.include?(label)
    end
  end

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

  def expand_synonyms(labels)
    labels.flat_map do |label|
      [label] + FOOD_SYNONYMS.fetch(label, [])
    end.uniq
  end

end
