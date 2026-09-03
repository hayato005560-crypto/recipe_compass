require "base64"
require "net/http"
require "uri"
require "json"

class VisionService
  API_URL = "https://vision.googleapis.com/v1/images:annotate"

  FOOD_LABELS = {
    "Broccoli" => "ブロッコリー",
    "Pasta" => "パスタ",
    "Spaghetti" => "パスタ",
    "Tomato" => "トマト",
    "Chicken" => "鶏肉",
    "Onion" => "玉ねぎ",
    "Pork" => "豚肉",
    "Cabbage" => "キャベツ"
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

    translate_food_labels(labels)
  end

  def extract_labels(result)
    annotations = result["responses"][0]["labelAnnotations"]

    annotations.map do |annotation|
      annotation["description"]
    end
  end

  def translate_food_labels(labels)
    labels.map do |label|
      FOOD_LABELS[label]
    end.compact.uniq
  end
end