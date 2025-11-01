class CreateUserRecipes < ActiveRecord::Migration[8.0]
  def change
    create_table :user_recipes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false

      t.timestamps
    end

    # Ensure a user cannot have two recipes with the same title
    add_index :user_recipes, [ :user_id, :title ], unique: true, name: 'index_user_recipes_on_user_id_and_title'
  end
end
