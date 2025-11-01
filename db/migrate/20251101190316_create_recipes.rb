class CreateRecipes < ActiveRecord::Migration[8.0]
  def change
    create_table :recipes do |t|
      t.string :title, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
