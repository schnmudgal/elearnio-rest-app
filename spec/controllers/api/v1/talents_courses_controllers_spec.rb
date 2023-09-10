require 'rails_helper'

RSpec.describe Api::V1::TalentsCoursesController, type: :controller do
  describe 'GET talents_courses: INDEX' do
    let!(:talent_1) { create :talent }
    let!(:talent_2) { create :talent }
    let!(:course_1) { create :course }
    let!(:course_2) { create :course }
    let!(:talent_1_course_1) { create :talents_course, talent: talent_1, course: course_1 }
    let!(:talent_2_course_2) { create :talents_course, talent: talent_2, course: course_2 }

    it 'returns all of the talents_courses json' do
      get :index

      expect(response.parsed_body['data']).to match_array([talent_1_course_1, talent_2_course_2].as_json(
        include: [:talent, :course]
      ))
    end

    context 'with "talent_id" filter' do
      it 'returns only talents_courses as per the given value of "talent_id" filter' do
        get :index, params: { talent_id: talent_1.id }

        expect(response.parsed_body['data']).to match_array([talent_1_course_1].as_json(
          include: [:talent, :course]
        ))
      end
    end

    context 'with "course_id" filter' do
      it 'returns only talents_courses associated with the given "course_id" filter' do
        get :index, params: { course_id: course_2.id }

        expect(response.parsed_body['data']).to match_array([talent_2_course_2].as_json(
          include: [:talent, :course]
        ))
      end
    end
  end

  describe 'POST talents_courses - Create a talents_course join association record' do
    let(:request) { post :create, params: { talents_course: talents_course_params } }
    let(:talent) { create :talent }
    let(:course) { create :course }

    context 'with valid data' do
      let(:talents_course_params) { {
        talent_id: talent.id,
        course_id: course.id
      } }

      it 'creates a new talents_courses joint association record' do
        expect{ request }.to change{ TalentsCourse.count }.by(1)
      end
    end

    context 'with invalid data' do
      let(:talents_course_params) { {
        talent_id: '',
        course_id: course.id
      } }

      it 'does NOT create a new talents_courses joint association record' do
        expect{ request }.not_to change{ TalentsCourse.count }
      end

      it 'returns specific error' do
        request

        expect(response.code).to eq('400')
        expect(response.parsed_body['errors']['talent']).to include('must exist')
      end
    end
  end

  describe 'POST start a talents course: start_course' do
    let(:request) { post :start_course, params: { talent_id: talent_id, course_id: course_id } }

    context 'when talent is NOT present' do
      let(:talent_id) { 0 }
      let(:course_id) { create(:course).id }

      it_behaves_like 'resource_not_foundable', TalentsCourse, 'Talents Course not found'
    end

    context 'when course is NOT present' do
      let(:talent_id) { create(:talent).id }
      let(:course_id) { 0 }

      it_behaves_like 'resource_not_foundable', TalentsCourse, 'Talents Course not found'
    end

    context 'when both talent and course are present' do
      let(:talent) { create :talent }
      let(:course) { create :course }
      let(:talent_id) { talent.id }
      let(:course_id) { course.id }
      let!(:talents_course) { create :talents_course, talent: talent, course: course, progress_status: 'enrolled' }

      it 'updates the progress status of given talents_course record to "in_progress"' do
        expect{ request }.to change{ talents_course.reload.progress_status }.from('enrolled').to('in_progress')
      end

      it 'sets the "started_at" timestamp' do
        request
        expect(talents_course.reload.started_at).not_to be_blank
      end
    end
  end

  describe 'POST pause a talents course: pause_course' do
    let(:request) { post :pause_course, params: { talent_id: talent_id, course_id: course_id } }

    context 'when talent is NOT present' do
      let(:talent_id) { 0 }
      let(:course_id) { create(:course).id }

      it_behaves_like 'resource_not_foundable', TalentsCourse, 'Talents Course not found'
    end

    context 'when course is NOT present' do
      let(:talent_id) { create(:talent).id }
      let(:course_id) { 0 }

      it_behaves_like 'resource_not_foundable', TalentsCourse, 'Talents Course not found'
    end

    context 'when both talent and course are present' do
      let(:talent) { create :talent }
      let(:course) { create :course }
      let(:talent_id) { talent.id }
      let(:course_id) { course.id }
      let!(:talents_course) { create :talents_course, talent: talent, course: course, progress_status: 'in_progress' }

      it 'updates the progress status of given talents_course record to "paused"' do
        expect{ request }.to change{ talents_course.reload.progress_status }.from('in_progress').to('paused')
      end

      it 'sets the "paused_at" timestamp' do
        request
        expect(talents_course.reload.paused_at).not_to be_blank
      end
    end
  end

  describe 'POST complete a talents course: complete_course' do
    let(:request) { post :complete_course, params: { talent_id: talent_id, course_id: course_id } }

    context 'when talent is NOT present' do
      let(:talent_id) { 0 }
      let(:course_id) { create(:course).id }

      it_behaves_like 'resource_not_foundable', TalentsCourse, 'Talents Course not found'
    end

    context 'when course is NOT present' do
      let(:talent_id) { create(:talent).id }
      let(:course_id) { 0 }

      it_behaves_like 'resource_not_foundable', TalentsCourse, 'Talents Course not found'
    end

    context 'when both talent and course are present' do
      let(:talent) { create :talent }
      let(:course) { create :course }
      let(:talent_id) { talent.id }
      let(:course_id) { course.id }
      let!(:talents_course) { create :talents_course, talent: talent, course: course, progress_status: 'in_progress' }

      it 'updates the progress status of given talents_course record to "completed"' do
        expect{ request }.to change{ talents_course.reload.progress_status }.from('in_progress').to('completed')
      end

      it 'sets the "completed_at" timestamp' do
        request
        expect(talents_course.reload.completed_at).not_to be_blank
      end
    end
  end

  describe 'POST disenroll_course a talents course: disenroll_course' do
    let(:request) { post :disenroll_course, params: { talent_id: talent_id, course_id: course_id } }

    context 'when talent is NOT present' do
      let(:talent_id) { 0 }
      let(:course_id) { create(:course).id }

      it_behaves_like 'resource_not_foundable', TalentsCourse, 'Talents Course not found'
    end

    context 'when course is NOT present' do
      let(:talent_id) { create(:talent).id }
      let(:course_id) { 0 }

      it_behaves_like 'resource_not_foundable', TalentsCourse, 'Talents Course not found'
    end

    context 'when both talent and course are present' do
      let(:talent) { create :talent }
      let(:course) { create :course }
      let(:talent_id) { talent.id }
      let(:course_id) { course.id }
      let!(:talents_course) { create :talents_course, talent: talent, course: course, progress_status: 'in_progress' }

      it 'removes the talents_course joint association record and thus disenrolls the course' do
        expect{ request }.to change{ TalentsCourse.count }.by(-1)
      end
    end
  end
end
