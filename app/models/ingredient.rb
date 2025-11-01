class Ingredient < ApplicationRecord
  # Associations with system recipes
  has_many :recipe_ingredients, dependent: :destroy
  has_many :recipes, through: :recipe_ingredients

  # Associations with user-generated recipes
  has_many :user_recipe_ingredients, dependent: :destroy
  has_many :user_recipes, through: :user_recipe_ingredients

  # Validations
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }
end
