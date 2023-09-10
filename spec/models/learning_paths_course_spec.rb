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
require 'rails_helper'

RSpec.describe LearningPathsCourse, type: :model do
  describe 'Concerns' do
    describe 'include: ProgressStatusActionable' do
      it_behaves_like 'progress_status_actionable'
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:course) }
    it { is_expected.to belong_to(:learning_path) }
  end

  describe 'Validations' do
    it { is_expected.to validate_inclusion_of(:progress_status).in_array(LearningPathsCourse::PROGRESS_STATUSES) }
  end

  describe 'Callbacks' do
    describe 'after_create :actions_once_complete' do
      let(:course_1) { create :course }
      let(:course_2) { create :course }
      let(:learning_path) {
        create(:learning_path,
          current_position: 1,
          learning_paths_courses_attributes: [
            { course_id: course_1.id, position: 1 },
            { course_id: course_2.id, position: 2 },
          ]
        )
      }

      let(:first_learning_paths_course) { learning_path.learning_paths_courses.first }
      let(:last_learning_paths_course) { learning_path.learning_paths_courses.last }

      context 'when the "learning_paths_course" marked completed is not the last one in the list' do
        it 'marks self complete and sets the next "current_position" in the parent "learning_path" to the next position' do
          expect{ first_learning_paths_course.complete! }.to change{ learning_path.reload.current_position }.from(1).to(2)
        end

        it 'does NOT mark parent "learning_path" as complete' do
          first_learning_paths_course.complete!

          expect(learning_path.reload.progress_status).not_to eq('completed')
        end
      end

      context 'when the "learning_paths_course" marked completed IS the last one in the list' do
        before { learning_path.update(current_position: 2) }

        it 'marks self complete and marks parent "learning_path" as complete' do
          last_learning_paths_course.complete!

          expect(learning_path.reload.progress_status).to eq('completed')
        end
      end
    end
  end

  describe 'Public instance methods' do
    describe '#last_item?' do
      let(:course_1) { create :course }
      let(:course_2) { create :course }
      let(:learning_path) {
        create(:learning_path,
          current_position: 1,
          learning_paths_courses_attributes: [
            { course_id: course_1.id, position: 1 },
            { course_id: course_2.id, position: 2 },
          ]
        )
      }

      let(:first_learning_paths_course) { learning_path.learning_paths_courses.first }
      let(:last_learning_paths_course) { learning_path.learning_paths_courses.last }

      context 'for the learning_paths_course which is last in the list' do
        it 'returns true' do
          expect(last_learning_paths_course.last_item?).to be(true)
        end
      end

      context 'for the learning_paths_course which is NOT the last one in the list' do
        it 'returns true' do
          expect(first_learning_paths_course.last_item?).to be(false)
        end
      end
    end
  end

end
