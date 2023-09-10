class CreateCourse < ActiveRecord::Migration[6.1]
  def change
    create_table :courses do |t|
      t.string :title, null: false
      t.string :description, null: false
      t.string :language, default: 'en', null: false
      t.boolean :active, default: false, null: false

      t.references :author, foreign_key: { to_table: :users }, null: false

      t.timestamps
    end
  end
end
