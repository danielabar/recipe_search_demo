class UserRecipeIngredient < ApplicationRecord
  belongs_to :user_recipe
  belongs_to :ingredient

  validates :user_recipe, presence: true
  validates :ingredient, presence: true

  validates :ingredient_id, uniqueness: { scope: :user_recipe_id, message: "already added to this recipe" }
end
