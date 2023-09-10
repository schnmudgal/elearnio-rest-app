require 'rails_helper'

RSpec.describe LearningPathService do
  describe '.add_courses' do

    context 'when learning_path is NOT present' do
      it 'raises exception' do
        expect{ LearningPathService.add_courses(0, []) }.to raise_error(RuntimeError)
      end
    end

    context 'when learning_path is present' do
      let(:learning_path) { create :learning_path }
      let(:id) { learning_path.id }
      let!(:course_1) { create :course }
      let!(:course_2) { create :course }
      let(:add_courses_data) {
        [
          { course_id: course_1.id, position: 1 },
          { course_id: course_2.id, position: 2 }
        ]
      }

      it 'adds the courses to the learning_path' do
        expect{ LearningPathService.add_courses(learning_path.id, add_courses_data) }.to change{ learning_path.courses.reload.count }.by(2)
      end
    end
  end

  describe '.remove_courses' do

    context 'when learning_path is NOT present' do
      it 'raises exception' do
        expect{ LearningPathService.remove_courses(0, []) }.to raise_error(RuntimeError)
      end
    end

    context 'when learning_path is present' do
      let!(:course_1) { create :course }
      let!(:course_2) { create :course }
      let(:learning_path) { create :learning_path,
        current_position: 1,
        learning_paths_courses_attributes: [{ course_id: course_1.id, position: 1 }, { course_id: course_2.id, position: 2 }]
      }
      let(:id) { learning_path.id }
      let(:course_ids) { [course_2.id] }

      it 'removes the courses from the learning_path' do
        expect{ LearningPathService.remove_courses(learning_path.id, course_ids) }.to change{ learning_path.courses.reload.count }.by(-1)
      end

      context 'when deleted course is current_course' do
        let(:course_ids) { [course_1.id] }

        it 'updates the current_course to the next available course' do
          expect{ LearningPathService.remove_courses(learning_path.id, course_ids) }.to change{ learning_path.reload.current_course.id }.from(course_1.id).to(course_2.id)
        end
      end
    end
  end
end
