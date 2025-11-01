# In a real application, this join table would likely include additional columns
# such as quantity (amount of ingredient), unit of measurement, and order
# (sequence in which ingredients are used in the recipe). However, for this
# simple demo focused on PostgreSQL full-text search capabilities, we're
# keeping the relationship minimal to focus on the search functionality.
class UserRecipeIngredient < ApplicationRecord
  belongs_to :user_recipe
  belongs_to :ingredient

  validates :user_recipe, presence: true
  validates :ingredient, presence: true

  validates :ingredient_id, uniqueness: { scope: :user_recipe_id, message: "already added to this recipe" }
end
