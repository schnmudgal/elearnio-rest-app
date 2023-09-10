class CreateLearningPathsCourses < ActiveRecord::Migration[6.1]
  def change
    create_table :learning_paths_courses do |t|
      t.references :learning_path, null: false
      t.references :course, null: false

      t.string :progress_status, default: 'enrolled', null: false # ['enrolled', 'in_progress', 'paused', 'completed']
      t.datetime :started_at
      t.datetime :paused_at
      t.datetime :completed_at

      t.integer :position, default: 1, null: false

      t.timestamps
    end
  end
end
