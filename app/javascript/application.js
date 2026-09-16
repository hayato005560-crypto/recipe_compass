// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"

// レシピ画像のプレビュー表示
document.addEventListener("turbo:load", () => {
  const imageInput = document.getElementById("recipe-image-input")
  const imagePreview = document.getElementById("recipe-image-preview")

  // 対象要素が存在しない画面では処理を終了
  if (!imageInput || !imagePreview) return

  imageInput.addEventListener("change", (event) => {
    const file = event.target.files[0]

    // ファイルが選択されていなければ終了
    if (!file) return

    const reader = new FileReader()

    // 読み込んだ画像をプレビューへ表示
    reader.onload = (event) => {
      imagePreview.src = event.target.result
      imagePreview.classList.remove("d-none")
    }

    reader.readAsDataURL(file)
  })
})
