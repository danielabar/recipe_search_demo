# Recipe Search Demo

A Rails 8 demo application serving as a companion to a blog post about lessons learned implementing site-wide search with PostgreSQL full-text search and the `pg_search` gem.

## Features

- User authentication with secure passwords
- Recipe and ingredient management
- Optimized CSV-based seeding for large datasets
- PostgreSQL full-text search (coming soon)

## Prerequisites

- Ruby 3.4.6 (see [.ruby-version](.ruby-version))
- Docker and Docker Compose
- Bundler

## Setup

1. **Start the database:**
   ```bash
   docker compose up
   ```

2. **Install dependencies and setup the application:**
   ```bash
   bin/setup
   ```

## Database Seeding

This project includes optimized CSV-based seeding for generating large datasets suitable for search performance testing:

- **Users:** 10,000 (configurable via `SEED_USERS`)
- **System Recipes:** 10,000 (configurable via `SEED_SYSTEM_RECIPES`)
- **User Recipes:** 1,500,000 (configurable via `SEED_USER_RECIPES`)
- **Ingredients:** Sourced from USDA food data in [db/seed_data/ingredients_usda.csv](db/seed_data/ingredients_usda.csv)

The seeding process uses PostgreSQL's `COPY` command for efficient bulk loading.
