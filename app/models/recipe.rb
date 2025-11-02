class Recipe < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [ :title ]

  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients

  validates :title, presence: true, uniqueness: { case_sensitive: false }
end
