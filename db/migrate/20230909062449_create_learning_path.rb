class CreateLearningPath < ActiveRecord::Migration[6.1]
  def change
    create_table :learning_paths do |t|
      t.references :talent, foreign_key: { to_table: :users }, null: false

      t.integer :current_position, default: 1
      t.string :progress_status, default: 'enrolled', null: false # ['enrolled', 'in_progress', 'paused', 'completed']
      t.datetime :started_at
      t.datetime :paused_at
      t.datetime :completed_at

      t.timestamps
    end
  end
end
