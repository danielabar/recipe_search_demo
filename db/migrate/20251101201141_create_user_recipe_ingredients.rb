class CreateUserRecipeIngredients < ActiveRecord::Migration[8.0]
  def change
    create_table :user_recipe_ingredients do |t|
      t.references :user_recipe, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_recipe_ingredients, [ :user_recipe_id, :ingredient_id ], unique: true, name: 'index_unq_on_user_recipe_id_and_ingredient_id'
  end
end
