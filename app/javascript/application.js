// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"

document.addEventListener("turbo:load", () => {
  const imageInput = document.getElementById("recipe-image-input")
  const imagePreview = document.getElementById("recipe-image-preview")

  if (!imageInput || !imagePreview) return

  imageInput.addEventListener("change", (event) => {
    const file = event.target.files[0]

    if (!file) return

    const reader = new FileReader()

    reader.onload = (event) => {
      imagePreview.src = event.target.result
      imagePreview.classList.remove("d-none")
    }

    reader.readAsDataURL(file)
  })
})