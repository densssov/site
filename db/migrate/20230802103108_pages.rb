class Pages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.integer :parent_id
      t.string :name, index: true
      t.string :header
      t.text :description

      t.timestamps
    end
  end
end
