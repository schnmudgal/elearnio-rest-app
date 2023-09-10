class Api::V1::TalentsCoursesController < Api::V1::BaseController
  before_action :find_talents_course_by_talent_and_course, only: [:disenroll_course, :start_course, :pause_course, :complete_course]

  def index
    @talents_courses = TalentsCourse.all

    @talents_courses = @talents_courses.where(talent_id: params[:talent_id]) if params[:talent_id].present?
    @talents_courses = @talents_courses.where(course_id: params[:course_id]) if params[:course_id].present?

    render_success_response(data: @talents_courses.includes(:talent, :course).as_json(
      include: [:talent, :course]
    ))
  end

  def create
    @talents_course = TalentsCourse.new(talents_course_params)

    if @talents_course.save
      render_success_response(data: @talents_course, message: 'Course added successfully')
    else
      render_failure_reponse(data: talents_course_params, message: 'Course could not be added', errors: @talents_course.errors)
    end
  end

  def start_course
    if @talents_course.start!
      render_success_response(data: nil, message: 'Course started successfully')
    else
      render_failure_reponse(data: nil, errors: @talents_course.errors)
    end
  end

  def pause_course
    if @talents_course.pause!
      render_success_response(data: nil, message: 'Course paused successfully')
    else
      render_failure_reponse(data: nil, errors: @talents_course.errors)
    end
  end

  def complete_course
    if @talents_course.complete!
      render_success_response(data: nil, message: 'Course completed successfully')
    else
      render_failure_reponse(data: nil, errors: @talents_course.errors)
    end
  end

  def disenroll_course
    if @talents_course.destroy!
      render_success_response(data: nil, message: 'Course disenrolled successfully')
    else
      render_failure_reponse(data: nil, errors: @talents_course.errors)
    end
  end

  private

  def find_talents_course_by_talent_and_course
    @talents_course = TalentsCourse.find_by(talent_id: params[:talent_id], course_id: params[:course_id])

    render_failure_reponse(message: 'Talents Course not found', errors: ['Talents Course not found'], status_code: '404') unless @talents_course
  end

  def talents_course_params
    params.require(:talents_course).permit(:talent_id, :course_id)
  end
end
