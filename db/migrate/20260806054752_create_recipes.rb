class CreateRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :recipes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body
      t.text :ingredients, null: false
      t.text :steps, null: false
      t.integer :cooking_time, null: false

      t.timestamps
    end
  end
end
