require 'rails_helper'

def learning_path_json_response_attributes
  {
    include: [
      {
        learning_paths_courses: {
          only: [:id, :position, :progress_status, :started_at, :paused_at, :completed_at],
          include: [{ course: { only: [:id, :language, :title] } }]
        }
      }
    ]
  }
end

RSpec.describe Api::V1::LearningPathsController, type: :controller do
  describe 'GET talents_courses: INDEX' do
    let!(:talent_1) { create :talent }
    let!(:talent_2) { create :talent }
    let!(:course_1) { create :course }
    let!(:course_2) { create :course }
    let!(:learning_path_1) {
      create(:learning_path,
        talent: talent_1,
        current_position: 1,
        progress_status: 'enrolled',
        learning_paths_courses_attributes: [
          { course_id: course_1.id, position: 1 },
        ]
      )
    }
    let!(:learning_path_2) {
      create(:learning_path,
        talent: talent_2,
        current_position: 2,
        progress_status: 'in_progress',
        learning_paths_courses_attributes: [
          { course_id: course_2.id, position: 1 },
        ]
      )
    }

    it 'returns all of the learning_paths json' do
      get :index

      expect(response.parsed_body['data']).to match_array([learning_path_1, learning_path_2].as_json(learning_path_json_response_attributes))
    end

    context 'with "progress_status" filter' do
      it 'returns only learning_paths as per the given value of "progress_status" filter' do
        get :index, params: { progress_status: 'in_progress' }

        expect(response.parsed_body['data']).to match_array([learning_path_2].as_json(learning_path_json_response_attributes))
      end
    end

    context 'with "talent_id" filter' do
      it 'returns only learning_paths associated with the given "talent_id" filter' do
        get :index, params: { talent_id: talent_1.id }

        expect(response.parsed_body['data']).to match_array([learning_path_1].as_json(learning_path_json_response_attributes))
      end
    end
  end

  describe 'GET learning_path: SHOW' do
    let(:request) { get :show, params: { id: id } }

    context 'when learning_path is NOT present' do
      let(:id) { 0 }
      it_behaves_like 'resource_not_foundable', LearningPath, 'Learning Path not found'
    end

    context 'when learning_path is present' do
      let(:learning_path) { create :learning_path }
      let(:id) { learning_path.id }

      it 'returns the learning_path json' do
        request

        expect(response.parsed_body['data']).to eq(learning_path.as_json(learning_path_json_response_attributes))
      end
    end
  end

  describe 'POST learning_paths - Create a learning_path' do
    let(:request) { post :create, params: { learning_path: learning_path_params } }
    let(:talent) { create :talent }
    let(:course) { create :course }

    context 'with valid data' do
      let(:learning_path_params) { {
        talent_id: talent.id,
        learning_paths_courses_attributes: [
          { course_id: course.id, position: 1 },
        ]
      } }

      it 'creates a new LearningPath' do
        expect{ request }.to change{ LearningPath.count }.by(1)
      end
    end

    context 'with invalid data' do
      let(:learning_path_params) { {
        talent_id: nil,
        learning_paths_courses_attributes: [
          { course_id: course.id, position: 1 },
        ]
      } }

      it 'does NOT create a new LearningPath' do
        expect{ request }.not_to change{ LearningPath.count }
      end

      it 'returns specific error' do
        request

        expect(response.code).to eq('400')
        expect(response.parsed_body['errors']['talent']).to include('must exist')
      end
    end
  end

  describe 'PATCH learning_paths - Update a learning_path' do
    let(:request) { patch :update, params: { id: id, learning_path: learning_path_params } }

    context 'when learning_path is NOT present' do
      let(:learning_path_params) { { talent_id: nil } }

      let(:id) { 0 }
      it_behaves_like 'resource_not_foundable', LearningPath, 'Learning Path not found'
    end

    context 'when learning_path is present' do
      let(:learning_path) { create :learning_path }
      let(:id) { learning_path.id }

      context 'with valid data' do
        let(:talent) { create :talent }
        let(:learning_path_params) { { talent_id: talent.id } }

        it 'updates the LearningPath' do
          expect{ request }.to change{ learning_path.reload.talent_id }.to(learning_path_params[:talent_id])
        end
      end

      context 'with invalid data' do
        let(:learning_path_params) { { talent_id: nil } }

        it 'does NOT update the LearningPath' do
          expect{ request }.not_to change{ learning_path.reload.talent_id }
        end

        it 'returns specific error' do
          request

          expect(response.code).to eq('400')
          expect(response.parsed_body['errors']['talent']).to include('must exist')
        end
      end
    end
  end

  describe 'DELETE learning_paths/:id - Deletes a learning_path' do
    let(:request) { delete :destroy, params: { id: id } }

    context 'when learning_path is NOT present' do
      let(:id) { 0 }
      it_behaves_like 'resource_not_foundable', LearningPath, 'Learning Path not found'
    end

    context 'when learning_path is present' do
      let!(:learning_path) { create :learning_path }
      let(:id) { learning_path.id }

      it 'deletes the learning_path' do
        expect{ request }.to change{ LearningPath.count }.by(-1)
      end
    end
  end

  describe 'POST learning_paths/:id/add_courses - Adds courses to an existing learning_path' do
    let(:request) { post :add_courses, params: { id: id, learning_path: add_courses_params } }

    context 'when learning_path is NOT present' do
      let(:add_courses_params) { nil }

      let(:id) { 0 }
      it_behaves_like 'resource_not_foundable', LearningPath, 'Learning Path not found'
    end

    context 'when learning_path is present' do
      let!(:learning_path) { create :learning_path }
      let(:id) { learning_path.id }
      let!(:course_1) { create :course }
      let!(:course_2) { create :course }
      let(:add_courses_params) {
        { learning_paths_courses_attributes: [{ course_id: course_1.id, position: 2 }, { course_id: course_2.id, position: 3 }] }
      }

      it 'adds the courses to the learning_path' do
        expect{ request }.to change{ learning_path.courses.reload.count }.by(2)
      end
    end
  end

  describe 'POST learning_paths/:id/remove_courses - Adds courses to an existing learning_path' do
    let(:request) { post :remove_courses, params: { id: id, course_ids: remove_courses_ids } }

    context 'when learning_path is NOT present' do
      let(:remove_courses_ids) { nil }

      let(:id) { 0 }
      it_behaves_like 'resource_not_foundable', LearningPath, 'Learning Path not found'
    end

    context 'when learning_path is present' do
      let!(:course_1) { create :course }
      let!(:course_2) { create :course }
      let!(:learning_path) { create :learning_path,
        current_position: 0,
        learning_paths_courses_attributes: [
          { course_id: course_1.id, position: 2 },
          { course_id: course_2.id, position: 3 },
        ]
      }
      let(:id) { learning_path.id }
      let(:remove_courses_ids) { [course_1.id] }


      it 'adds the courses to the learning_path' do
        expect{ request }.to change{ learning_path.courses.reload.count }.by(-1)
      end
    end
  end

  describe 'POST learning_paths/:id/start_course' do
    let(:request) { post :start_course, params: { id: id, course_id: course_id } }

    context 'when learning_path is NOT present' do
      let(:id) { 0 }
      let(:course_id) { 0 }

      it_behaves_like 'resource_not_foundable', LearningPath, 'Learning Path not found'
    end

    context 'when course is NOT present' do
      let!(:course_1) { create :course }
      let!(:course_2) { create :course }
      let!(:learning_path) { create :learning_path,
        current_position: 0,
        learning_paths_courses_attributes: [
          { course_id: course_1.id, position: 2 },
          { course_id: course_2.id, position: 3 },
        ]
      }
      let(:id) { learning_path.id }
      let(:course_id) { 0 }

      it_behaves_like 'resource_not_foundable', LearningPath, 'Course not found in this Learning Path'
    end

    context 'when both learning_path and course are present' do
      let!(:course_1) { create :course }
      let!(:course_2) { create :course }
      let!(:learning_path) { create :learning_path,
        current_position: 0,
        learning_paths_courses_attributes: [
          { course_id: course_1.id, position: 2 },
          { course_id: course_2.id, position: 3 },
        ]
      }
      let(:first_learning_paths_course) { learning_path.learning_paths_courses.first }
      let(:last_learning_paths_course) { learning_path.learning_paths_courses.last }
      let(:id) { learning_path.id }
      let(:course_id) { course_1.id }

      it 'updates the progress status of given course record to "in_progress"' do
        expect{ request }.to change{ first_learning_paths_course.reload.progress_status }.from('enrolled').to('in_progress')
      end

      it 'sets the "started_at" timestamp' do
        request
        expect(first_learning_paths_course.reload.started_at).not_to be_blank
      end
    end
  end

  describe 'POST pause a talents course: pause_course' do
    let(:request) { post :pause_course, params: { id: id, course_id: course_id } }

    context 'when learning_path is NOT present' do
      let(:id) { 0 }
      let(:course_id) { 0 }

      it_behaves_like 'resource_not_foundable', LearningPath, 'Learning Path not found'
    end

    context 'when course is NOT present' do
      let!(:course_1) { create :course }
      let!(:course_2) { create :course }
      let!(:learning_path) { create :learning_path,
        current_position: 0,
        learning_paths_courses_attributes: [
          { course_id: course_1.id, position: 2 },
          { course_id: course_2.id, position: 3 },
        ]
      }
      let(:id) { learning_path.id }
      let(:course_id) { 0 }

      it_behaves_like 'resource_not_foundable', LearningPath, 'Course not found in this Learning Path'
    end

    context 'when both learning_path and course are present' do
      let!(:course_1) { create :course }
      let!(:course_2) { create :course }
      let!(:learning_path) { create :learning_path,
        current_position: 0,
        learning_paths_courses_attributes: [
          { course_id: course_1.id, position: 2 },
          { course_id: course_2.id, position: 3 },
        ]
      }
      let(:first_learning_paths_course) { learning_path.learning_paths_courses.first }
      let(:last_learning_paths_course) { learning_path.learning_paths_courses.last }
      let(:id) { learning_path.id }
      let(:course_id) { course_1.id }

      it 'updates the progress status of given course record to "paused"' do
        expect{ request }.to change{ first_learning_paths_course.reload.progress_status }.from('enrolled').to('paused')
      end

      it 'sets the "paused_at" timestamp' do
        request
        expect(first_learning_paths_course.reload.paused_at).not_to be_blank
      end
    end
  end

  describe 'POST complete a talents course: complete_course' do
    let(:request) { post :complete_course, params: { id: id, course_id: course_id } }

    context 'when learning_path is NOT present' do
      let(:id) { 0 }
      let(:course_id) { 0 }

      it_behaves_like 'resource_not_foundable', LearningPath, 'Learning Path not found'
    end

    context 'when course is NOT present' do
      let!(:course_1) { create :course }
      let!(:course_2) { create :course }
      let!(:learning_path) { create :learning_path,
        current_position: 0,
        learning_paths_courses_attributes: [
          { course_id: course_1.id, position: 2 },
          { course_id: course_2.id, position: 3 },
        ]
      }
      let(:id) { learning_path.id }
      let(:course_id) { 0 }

      it_behaves_like 'resource_not_foundable', LearningPath, 'Course not found in this Learning Path'
    end

    context 'when both learning_path and course are present' do
      let!(:course_1) { create :course }
      let!(:course_2) { create :course }
      let!(:learning_path) { create :learning_path,
        current_position: 0,
        learning_paths_courses_attributes: [
          { course_id: course_1.id, position: 2 },
          { course_id: course_2.id, position: 3 },
        ]
      }
      let(:first_learning_paths_course) { learning_path.learning_paths_courses.first }
      let(:last_learning_paths_course) { learning_path.learning_paths_courses.last }
      let(:id) { learning_path.id }
      let(:course_id) { course_1.id }

      it 'updates the current_course id' do
        expect{ request }.to change{ learning_path.reload.current_course.id }.from(course_1.id).to(course_2.id)
      end

      it 'updates the progress status of given course record to "completed"' do
        expect{ request }.to change{ first_learning_paths_course.reload.progress_status }.from('enrolled').to('completed')
      end

      it 'sets the "completed_at" timestamp' do
        request
        expect(first_learning_paths_course.reload.completed_at).not_to be_blank
      end
    end
  end
end
