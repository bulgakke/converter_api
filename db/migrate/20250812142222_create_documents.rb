class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.text :svg_content, null: false

      t.timestamps
    end
  end
end
