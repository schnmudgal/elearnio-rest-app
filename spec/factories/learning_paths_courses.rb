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
FactoryBot.define do
  factory :learning_paths_course do
    learning_path
    course
    progress_status { 'enrolled' }
  end
end
