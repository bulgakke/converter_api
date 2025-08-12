class AddSVGContentHashToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :svg_content_hash, :string, null: false
    add_index :documents, :svg_content_hash, unique: true
  end
end
