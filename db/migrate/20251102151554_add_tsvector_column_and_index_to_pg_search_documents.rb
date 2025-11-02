class AddTsvectorColumnAndIndexToPgSearchDocuments < ActiveRecord::Migration[8.0]
  def up
    add_column :pg_search_documents, :content_vector, :tsvector

    execute <<~SQL
      CREATE TRIGGER pg_search_documents_content_vector_update
      BEFORE INSERT OR UPDATE ON pg_search_documents
      FOR EACH ROW EXECUTE FUNCTION
        tsvector_update_trigger(
          content_vector, 'pg_catalog.english', content
        );
    SQL

    execute <<~SQL
      CREATE INDEX index_pg_search_documents_on_content_vector
      ON pg_search_documents USING GIN (content_vector);
    SQL

    execute <<~SQL
      UPDATE pg_search_documents
      SET content_vector = to_tsvector('pg_catalog.english', content)
      WHERE content IS NOT NULL;
    SQL
  end

  def down
    execute "DROP INDEX IF EXISTS index_pg_search_documents_on_content_vector;"
    execute "DROP TRIGGER IF EXISTS pg_search_documents_content_vector_update ON pg_search_documents;"
    remove_column :pg_search_documents, :content_vector
  end
end
