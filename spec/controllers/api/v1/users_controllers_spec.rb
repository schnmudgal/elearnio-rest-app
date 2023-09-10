require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  describe 'GET users: INDEX' do
    let!(:user_1) { create :user }
    let!(:user_2) { create :user }

    it 'returns all of the users json' do
      get :index

      expect(response.parsed_body['data']).to match_array(JSON.parse([user_1, user_2].to_json))
    end
  end

  describe 'GET user: SHOW' do
    let(:request) { get :show, params: { id: id } }

    context 'when user is NOT present' do
      let(:id) { 0 }
      it_behaves_like 'resource_not_foundable', User, 'User not found'
    end

    context 'when user is present' do
      let(:user) { create :user }
      let(:id) { user.id }

      it 'returns the user json' do
        request

        expect(response.parsed_body['data']).to eq(user.as_json)
      end
    end
  end

  describe 'POST users - Create a user' do
    let(:request) { post :create, params: { user: user_params } }

    context 'with valid data' do
      let(:user_params) { {
        name: Faker::Name.name,
        email: Faker::Internet.email
      } }

      it 'creates a new User' do
        expect{ request }.to change{ User.count }.by(1)
      end
    end

    context 'with invalid data' do
      let(:user_params) { {
        name: '',
        email: Faker::Internet.email
      } }

      it 'does NOT create a new User' do
        expect{ request }.not_to change{ User.count }
      end

      it 'returns specific error' do
        request

        expect(response.code).to eq('400')
        expect(response.parsed_body['errors']['name']).to include("can't be blank")
      end
    end
  end

  describe 'PATCH users - Update a user' do
    let(:request) { patch :update, params: { id: id, user: user_params } }

    context 'when user is NOT present' do
      let(:user_params) { { name: 'Updated name' } }

      let(:id) { 0 }
      it_behaves_like 'resource_not_foundable', User, 'User not found'
    end

    context 'when user is present' do
      let(:user) { create :user }
      let(:id) { user.id }

      context 'with valid data' do
        let(:user_params) { { name: 'Updated name' } }

        it 'updates the User' do
          expect{ request }.to change{ user.reload.name }.to(user_params[:name])
        end
      end

      context 'with invalid data' do
        let(:user_params) { { name: '' } }

        it 'does NOT update the User' do
          expect{ request }.not_to change{ user.reload.name }
        end

        it 'returns specific error' do
          request

          expect(response.code).to eq('400')
          expect(response.parsed_body['errors']['name']).to include("can't be blank")
        end
      end
    end
  end

  describe 'DELETE users/:id - Deletes a user' do
    let(:request) { delete :destroy, params: { id: id } }

    context 'when user is NOT present' do
      let(:id) { 0 }
      it_behaves_like 'resource_not_foundable', User, 'User not found'
    end

    context 'when user is present' do
      let!(:user) { create :user }
      let(:id) { user.id }

      it 'deletes the user' do
        expect{ request }.to change{ User.count }.by(-1)
      end
    end
  end

  describe 'GET My Learning Paths: my_learning_paths' do
    let(:request) { get :my_learning_paths, params: { id: id } }

    context 'when user is NOT present' do
      let(:id) { 0 }
      it_behaves_like 'resource_not_foundable', User, 'User not found'
    end

    context 'when user is present' do
      let(:user) { create :user }
      let(:id) { user.id }

      let(:course_1) { create :course }
      let(:course_2) { create :course }
      let!(:learning_path_1) {
        create(:learning_path,
          talent: user.as_talent,
          current_position: 1,
          learning_paths_courses_attributes: [
            { course_id: course_1.id, position: 1 },
          ]
        )
      }
      let!(:learning_path_2) {
        create(:learning_path,
          talent: user.as_talent,
          current_position: 2,
          learning_paths_courses_attributes: [
            { course_id: course_2.id, position: 1 },
          ]
        )
      }

      it 'returns the users learning paths list' do
        request

        expect(response.parsed_body['data']).to match_array(
          [learning_path_1, learning_path_2].as_json(
            include: [
              {
                learning_paths_courses: {
                  only: [:id, :position, :progress_status],
                  include: [{ course: { only: [:id, :language, :title] } }]
                }
              }
            ]
          )
        )
      end
    end
  end

  describe 'GET My Enrolled Courses: my_enrolled_courses' do
    let(:request) { get :my_enrolled_courses, params: { id: id } }

    context 'when user is NOT present' do
      let(:id) { 0 }
      it_behaves_like 'resource_not_foundable', User, 'User not found'
    end

    context 'when user is present' do
      let(:user) { create :user }
      let(:id) { user.id }

      let(:course_1) { create :course }
      let(:course_2) { create :course }
      let!(:talents_course_1) { create(:talents_course, talent: user.as_talent, course: course_1) }
      let!(:talents_course_2) { create(:talents_course, talent: user.as_talent, course: course_2) }

      it 'returns the users enrolled courses list' do
        request

        expect(response.parsed_body['data']).to match_array(
          [talents_course_1, talents_course_2].as_json(
            only: [:id, :progress_status],
            include: [
              { course: { only: [:id, :language, :title] } }
            ]
          )
        )
      end
    end
  end

  describe 'GET My Authored Courses: my_authored_courses' do
    let(:request) { get :my_authored_courses, params: { id: id } }

    context 'when user is NOT present' do
      let(:id) { 0 }
      it_behaves_like 'resource_not_foundable', User, 'User not found'
    end

    context 'when user is present' do
      let(:user) { create :user }
      let(:id) { user.id }

      let!(:course_1) { create :course, author: user.as_author }
      let!(:course_2) { create :course, author: user.as_author }

      it 'returns the users authored courses list' do
        request

        expect(response.parsed_body['data']).to match_array([course_1, course_2].as_json)
      end
    end
  end
end
