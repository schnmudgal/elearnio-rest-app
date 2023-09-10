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
require 'rails_helper'

RSpec.describe LearningPath, type: :model do
  describe 'Concerns' do
    describe 'include: ProgressStatusActionable' do
      it_behaves_like 'progress_status_actionable'
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:talent) }
    it { is_expected.to have_many(:learning_paths_courses).inverse_of(:learning_path).dependent(:destroy) }
    it { is_expected.to have_many(:courses).through(:learning_paths_courses) }
    it { is_expected.to accept_nested_attributes_for(:learning_paths_courses).allow_destroy(true) }
  end

  describe 'Validations' do
    it { is_expected.to validate_inclusion_of(:progress_status).in_array(LearningPath::PROGRESS_STATUSES) }

    describe 'Custom validations' do
      describe 'valid_start_and_complete_dates' do
        let(:learning_path) { build :learning_path }

        context 'when "completed_at" is after "started_at"' do
          before { learning_path.started_at, learning_path.completed_at = Time.current, Time.current + 1.day }

          it 'does not add any errors related to dates' do
            learning_path.valid?

            expect(learning_path.errors).to be_empty
          end
        end

        context 'when "completed_at" is before "started_at"' do
          before { learning_path.started_at, learning_path.completed_at = Time.current + 1.day, Time.current }

          it 'does not add any errors related to dates' do
            learning_path.valid?

            expect(learning_path.errors[:completed_at]).to include('completed_at time must be after started_at')
          end
        end
      end
    end
  end

  describe 'Scopes' do
    describe 'Dynamic scopes created for progress statues' do
      LearningPath::PROGRESS_STATUSES.each do |progress_status|
        let!("#{progress_status}_learning_path".to_sym) { create :learning_path, progress_status: progress_status }
      end

      LearningPath::PROGRESS_STATUSES.each do |progress_status|
        describe ".#{progress_status}" do
          it "returns only the learning_paths having progress_status as #{progress_status}" do
            expect(LearningPath.public_send(progress_status)).to match_array([public_send("#{progress_status}_learning_path")])
          end
        end
      end
    end

    describe '.having_progress_statuses' do
      LearningPath::PROGRESS_STATUSES.each do |progress_status|
        let!("#{progress_status}_learning_path".to_sym) { create :learning_path, progress_status: progress_status }
      end

      LearningPath::PROGRESS_STATUSES.each do |progress_status|
        describe ".#{progress_status}" do
          it "returns only the learning_paths having progress_status as #{progress_status}" do
            expect(LearningPath.having_progress_statuses(progress_status)).to match_array([public_send("#{progress_status}_learning_path")])
          end
        end
      end
    end

    describe '.of_talent' do
      let!(:learning_path) { create :learning_path }
      let(:talent) { create :talent }
      let(:talents_learning_path) { create :learning_path, talent: talent }

      it 'returns only those learning paths which are related to given talent' do
        expect(LearningPath.of_talent(talent.id)).to match_array([talents_learning_path])
      end
    end
  end

  describe 'Callbacks' do
    describe 'after_create :set_first_position' do
      let(:course_1) { create :course }
      let(:course_2) { create :course }
      let(:learning_path) {
        build(:learning_path,
          current_position: 0,
          learning_paths_courses_attributes: [
            { course_id: course_1.id, position: 1 },
            { course_id: course_2.id, position: 2 },
          ]
        )
      }

      context 'when current_position data is already given during create' do
        before { learning_path.current_position = 2 }

        it 'does NOT sets the current course' do
          learning_path.save

          expect(learning_path.reload.current_position).to eq(2)
        end
      end

      context 'when current_position data is NOT given during create' do
        it 'sets the current course based on position' do
          learning_path.save

          expect(learning_path.reload.current_position).to eq(1)
        end
      end
    end
  end

  describe 'Public instance methods' do

    describe '#current_learning_paths_course' do
      let(:course_1) { create :course }
      let(:course_2) { create :course }
      let(:learning_path) {
        create(:learning_path,
          current_position: 2,
          learning_paths_courses_attributes: [
            { course_id: course_1.id, position: 1 },
            { course_id: course_2.id, position: 2 },
          ]
        )
      }

      it 'returns "learning_paths_course" from the "learning_paths_courses" list as per "current_position"' do
        expect(learning_path.current_learning_paths_course.position).to eq(2)
      end
    end

    describe '#increament_position!' do
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

      it 'updates the "current_position" to next available course from the list of "learning_paths_courses" ordered by "position"' do

        expect{ learning_path.increament_position! }.to change{ learning_path.current_position }.from(1).to(2)
      end
    end

    describe 'Alias methods' do
      let!(:learning_path) { build :learning_path }

      it 'asserts that #mark_in_progress! as an alias of #start!' do
        expect(learning_path.method(:mark_in_progress!)).to eq(learning_path.method(:start!))
      end

      it 'asserts that #mark_paused! as an alias of #pause!' do
        expect(learning_path.method(:mark_paused!)).to eq(learning_path.method(:pause!))
      end

      it 'asserts that #mark_completed! as an alias of #complete!' do
        expect(learning_path.method(:mark_completed!)).to eq(learning_path.method(:complete!))
      end
    end
  end
end
