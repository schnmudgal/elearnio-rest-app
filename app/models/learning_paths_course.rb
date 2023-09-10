# frozen_string_literal: true

# == Schema Information
#
# Table name: learning_paths_courses
#
#  id               :bigint           not null, primary key
#  completed_at     :datetime
#  paused_at        :datetime
#  position         :integer          default(1), not null
#  progress_status  :string           default("enrolled"), not null
#  started_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  course_id        :bigint           not null
#  learning_path_id :bigint           not null
#
# Indexes
#
#  index_learning_paths_courses_on_course_id         (course_id)
#  index_learning_paths_courses_on_learning_path_id  (learning_path_id)
#
class LearningPathsCourse < ApplicationRecord

  # Inclusion and Extensions
  include ProgressStatusActionable

  # Associations
  belongs_to :course
  belongs_to :learning_path
  acts_as_list scope: :learning_path

  # Validations
  validates :progress_status, inclusion: { in: PROGRESS_STATUSES }

  # Callbacks
  after_save :actions_once_complete


  # Public class methods

  # This methods helps mostly only in conjunction with parent LearningCourse
  def self.first_item(after_position: nil)
    where('position > ?', after_position.to_i).first
  end

  # Public instance methods

  def last_item?
    learning_path.learning_paths_courses.last == self
  end

  # Private instance methods

  private

  def actions_once_complete
    if saved_change_to_progress_status?(to: PROGRESS_STATUSES_HASH[:completed])

      # Completing the learning path after last course in the sequence
      (learning_path.complete! and return) if self.reload.last_item?

      # Setting next course
      learning_path.increament_position!(after_position: position)
    end
  end
end
