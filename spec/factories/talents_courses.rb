# == Schema Information
#
# Table name: talents_courses
#
#  id              :bigint           not null, primary key
#  completed_at    :datetime
#  paused_at       :datetime
#  progress_status :string           default("enrolled"), not null
#  started_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  course_id       :bigint           not null
#  talent_id       :bigint           not null
#
# Indexes
#
#  index_talents_courses_on_course_id  (course_id)
#  index_talents_courses_on_talent_id  (talent_id)
#
# Foreign Keys
#
#  fk_rails_...  (talent_id => users.id)
#
FactoryBot.define do
  factory :talents_course do
    talent
    course
    progress_status { 'enrolled' }
  end
end
