# frozen_string_literal: true

# == Schema Information
#
# Table name: learning_paths
#
#  id               :bigint           not null, primary key
#  completed_at     :datetime
#  current_position :integer          default(1)
#  paused_at        :datetime
#  progress_status  :string           default("enrolled"), not null
#  started_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  talent_id        :bigint           not null
#
# Indexes
#
#  index_learning_paths_on_talent_id  (talent_id)
#
# Foreign Keys
#
#  fk_rails_...  (talent_id => users.id)
#
class LearningPath < ApplicationRecord

  # Inclusion and Extensions
  include ProgressStatusActionable

  # Associations
  belongs_to :talent

  has_many :learning_paths_courses, -> { order(position: :asc) }, inverse_of: :learning_path, dependent: :destroy
  has_many :courses, through: :learning_paths_courses

  accepts_nested_attributes_for :learning_paths_courses, allow_destroy: true

  # Validations
  validates :progress_status, inclusion: { in: PROGRESS_STATUSES }
  validate  :valid_start_and_complete_dates

  # Scopes

  ## Define dynamic scopes for different progress_statuses, i.e.
  ## ".enrolled", ".in_progress", '.paused', ".completed"
  PROGRESS_STATUSES.each do |progress_status|
    scope progress_status, -> { where(progress_status: progress_status) }
  end

  scope :having_progress_statuses, -> (progress_status) { where(progress_status: progress_status) }
  scope :of_talent, -> (talent_id) { where(talent_id: talent_id) }

  # Callbacks
  after_create :set_first_position


  # Public instance methods

  def current_learning_paths_course
    learning_paths_courses.find_by(position: current_position)
  end

  def current_course
    current_learning_paths_course&.course
  end

  def increament_position!(after_position: nil)
    after_position ||= current_learning_paths_course&.position

    update(current_position: learning_paths_courses.reload.first_item(after_position: after_position).position)
  end


  # Private instance methods
  private

  def valid_start_and_complete_dates
    return if completed_at.blank? || started_at.blank?

    if completed_at < started_at
      errors.add(:completed_at, 'completed_at time must be after started_at')
    end
  end

  def set_first_position
    return if current_course.present?
    return if learning_paths_courses.blank?

    update(current_position: learning_paths_courses.first_item.position)
  end
end
