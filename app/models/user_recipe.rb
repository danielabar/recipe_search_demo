class UserRecipe < ApplicationRecord
  belongs_to :user

  has_many :user_recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :user_recipe_ingredients

  validates :title,
            presence: true,
            uniqueness: { scope: :user_id, case_sensitive: false },
            length: { maximum: 255 }
end
