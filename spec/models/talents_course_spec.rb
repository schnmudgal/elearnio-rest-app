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
require 'rails_helper'

RSpec.describe TalentsCourse, type: :model do
  describe 'Concerns' do
    describe 'include: ProgressStatusActionable' do
      it_behaves_like 'progress_status_actionable'
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:talent) }
    it { is_expected.to belong_to(:course) }
  end

  describe 'Validations' do
    let(:subject) { build :talents_course }

    it { is_expected.to validate_inclusion_of(:progress_status).in_array(TalentsCourse::PROGRESS_STATUSES) }
    it { is_expected.to validate_uniqueness_of(:course_id).scoped_to(:talent_id) }
  end
end
