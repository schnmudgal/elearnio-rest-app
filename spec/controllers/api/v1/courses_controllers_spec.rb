require 'rails_helper'

RSpec.describe Api::V1::CoursesController, type: :controller do
  describe 'GET courses: INDEX' do
    let!(:author_1) { create :author }
    let!(:author_2) { create :author }
    let!(:author_1_and_active_course) { create :course, active: true, author: author_1 }
    let!(:author_2_and_inactive_course) { create :course, active: false, author: author_2 }

    it 'returns all of the courses json' do
      get :index

      expect(response.parsed_body['data']).to match_array(JSON.parse([author_1_and_active_course, author_2_and_inactive_course].to_json))
    end

    context 'with "active" filter' do
      it 'returns only courses as per the given value of "active" filter' do
        get :index, params: { active: true }

        expect(response.parsed_body['data']).to match_array([author_1_and_active_course].as_json)
      end
    end

    context 'with "author_id" filter' do
      it 'returns only courses associated with the given "author_id" filter' do
        get :index, params: { author_id: author_2 }

        expect(response.parsed_body['data']).to match_array([author_2_and_inactive_course].as_json)
      end
    end
  end

  describe 'GET course: SHOW' do
    let(:request) { get :show, params: { id: id } }

    context 'when course is NOT present' do
      let(:id) { 0 }
      it_behaves_like 'resource_not_foundable', Course, 'Course not found'
    end

    context 'when course is present' do
      let(:course) { create :course }
      let(:id) { course.id }

      it 'returns the course json' do
        request

        expect(response.parsed_body['data']).to eq(course.as_json)
      end
    end
  end

  describe 'POST courses - Create a course' do
    let(:request) { post :create, params: { course: course_params } }
    let(:author) { create :author }

    context 'with valid data' do
      let(:course_params) { {
        title: Faker::Lorem.sentence,
        description: Faker::Lorem.paragraph,
        author_id: author.id
      } }

      it 'creates a new course' do
        expect{ request }.to change{ Course.count }.by(1)
      end
    end

    context 'with invalid data' do
      let(:course_params) { {
        title: '',
        description: Faker::Lorem.paragraph,
        author_id: author.id
      } }

      it 'does NOT create a new Course' do
        expect{ request }.not_to change{ Course.count }
      end

      it 'returns specific error' do
        request

        expect(response.code).to eq('400')
        expect(response.parsed_body['errors']['title']).to include("can't be blank")
      end
    end
  end

  describe 'PATCH courses - Update a course' do
    let(:request) { patch :update, params: { id: id, course: course_params } }

    context 'when course is NOT present' do
      let(:course_params) { { title: 'Updated title' } }

      let(:id) { 0 }
      it_behaves_like 'resource_not_foundable', Course, 'Course not found'
    end

    context 'when course is present' do
      let(:course) { create :course }
      let(:id) { course.id }

      context 'with valid data' do
        let(:course_params) { { title: 'Updated title' } }

        it 'updates the Course' do
          expect{ request }.to change{ course.reload.title }.to(course_params[:title])
        end
      end

      context 'with invalid data' do
        let(:course_params) { { title: '' } }

        it 'does NOT update the Course' do
          expect{ request }.not_to change{ course.reload.title }
        end

        it 'returns specific error' do
          request

          expect(response.code).to eq('400')
          expect(response.parsed_body['errors']['title']).to include("can't be blank")
        end
      end
    end
  end

  describe 'DELETE courses/:id - Deletes a course' do
    let(:request) { delete :destroy, params: { id: id } }

    context 'when course is NOT present' do
      let(:id) { 0 }
      it_behaves_like 'resource_not_foundable', Course, 'Course not found'
    end

    context 'when course is present' do
      let!(:course) { create :course }
      let(:id) { course.id }

      it 'deletes the course' do
        expect{ request }.to change{ Course.count }.by(-1)
      end
    end
  end
end
