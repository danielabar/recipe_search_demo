class Recipe < ApplicationRecord
  include PgSearch::Model
  multisearchable(
    against: %i[title ingredient_names]
  )

  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients

  validates :title, presence: true, uniqueness: { case_sensitive: false }

  def ingredient_names
    ingredients.pluck(:name).join(" ")
  end

  # Bulk rebuild for pg_search_documents.
  #
  # Why this exists:
  # pg_search normally rebuilds documents by instantiating each Recipe and calling
  # its `ingredient_names` method. That means N queries + Ruby string-building,
  # which becomes slow as your dataset grows. This custom rebuild does everything
  # in a *single SQL statement*, making rebuilds fast and efficient.
  #
  # What the SQL does:
  # - Joins recipes → recipe_ingredients → ingredients
  # - Collects all ingredient names for each recipe using STRING_AGG
  # - Concatenates the recipe title + all ingredient names into one searchable
  #   `content` field (mirrors what multisearchable normally generates)
  # - Inserts one row per recipe into pg_search_documents
  #
  # Why GROUP BY is required:
  # After the JOIN, each recipe appears multiple times (one row per ingredient).
  # STRING_AGG collapses those rows into a single combined ingredient string.
  # Whenever an aggregate like STRING_AGG is used, all non-aggregated columns
  # (recipe ID and title) must be grouped so Postgres knows how to return exactly
  # one document row per recipe.
  def self.rebuild_pg_search_documents
    connection.execute <<~SQL.squish
      INSERT INTO pg_search_documents (searchable_type, searchable_id, content, created_at, updated_at)
      SELECT
        'Recipe' AS searchable_type,
        recipes.id AS searchable_id,
        CONCAT_WS(
          ' ',
          recipes.title,
          STRING_AGG(ingredients.name, ' ' ORDER BY ingredients.name)
        ) AS content,
        NOW() AS created_at,
        NOW() AS updated_at
      FROM recipes
      LEFT JOIN recipe_ingredients
        ON recipe_ingredients.recipe_id = recipes.id
      LEFT JOIN ingredients
        ON ingredients.id = recipe_ingredients.ingredient_id
      GROUP BY recipes.id, recipes.title
    SQL
  end

  # Batched rebuild version.
  #
  # When to use this version:
  # -------------------------
  # The non-batched rebuild (above) runs a single INSERT … SELECT that processes
  # every recipe at once. Postgres handles large set-based operations very well,
  # but once your dataset grows into the hundreds of thousands or millions of
  # recipes, a single massive insert can:
  #
  #   • Hold locks on pg_search_documents for longer
  #   • Create heavy, long-running GIN/GIST index updates
  #   • Increase I/O pressure or trigger autovacuum more aggressively
  #
  # The batched approach avoids those issues by breaking the rebuild into
  # smaller 10,000-recipe chunks. Each batch produces a smaller INSERT … SELECT
  # statement that completes quickly, reducing lock duration and index churn.
  #
  # When batching helps:
  # --------------------
  #   • Very large numbers of recipes (e.g., 500k+ or millions)
  #   • Limited database I/O bandwidth (containerized or shared DB)
  #   • You want rebuilds to complete with minimal impact on production traffic
  #
  # Tradeoffs:
  # ----------
  #   • Generates multiple INSERT statements instead of one
  #   • Slightly more overhead on the Ruby side (pluck per batch)
  #
  # For most applications, the single-query version is perfectly fine. Switch
  # to batching only when scale or production impact makes it worthwhile.

  # def self.rebuild_pg_search_documents
  #   Recipe.in_batches(of: 10_000) do |batch|
  #     ids = batch.pluck(:id)

  #     connection.execute <<~SQL.squish
  #       INSERT INTO pg_search_documents (searchable_type, searchable_id, content, created_at, updated_at)
  #       SELECT
  #         'Recipe' AS searchable_type,
  #         recipes.id AS searchable_id,
  #         CONCAT_WS(
  #           ' ',
  #           recipes.title,
  #           STRING_AGG(ingredients.name, ' ' ORDER BY ingredients.name)
  #         ) AS content,
  #         NOW() AS created_at,
  #         NOW() AS updated_at
  #       FROM recipes
  #       LEFT JOIN recipe_ingredients
  #         ON recipe_ingredients.recipe_id = recipes.id
  #       LEFT JOIN ingredients
  #         ON ingredients.id = recipe_ingredients.ingredient_id
  #       WHERE recipes.id IN (#{ids.join(",")})
  #       GROUP BY recipes.id, recipes.title
  #     SQL
  #   end
  # end
end
