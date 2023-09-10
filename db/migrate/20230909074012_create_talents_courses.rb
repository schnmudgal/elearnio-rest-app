class CreateTalentsCourses < ActiveRecord::Migration[6.1]
  def change
    create_table :talents_courses do |t|
      t.references :talent, foreign_key: { to_table: :users }, null: false
      t.references :course, null: false

      t.string :progress_status, default: 'enrolled', null: false # ['enrolled', 'in_progress', 'paused', 'completed']
      t.datetime :started_at
      t.datetime :paused_at
      t.datetime :completed_at

      t.timestamps
    end
  end
end
