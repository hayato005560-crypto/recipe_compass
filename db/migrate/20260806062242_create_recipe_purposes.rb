class CreateRecipePurposes < ActiveRecord::Migration[8.1]
  def change
    create_table :recipe_purposes do |t|
      t.references :recipe, null: false, foreign_key: true
      t.references :purpose, null: false, foreign_key: true

      t.timestamps
    end
    add_index :recipe_purposes,[:recipe_id, :purpose_id],unique: true
  end
end
