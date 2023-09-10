class Api::V1::CoursesController < Api::V1::BaseController
  before_action :find_course, only: [:show, :update, :destroy]

  def index
    @courses = Course.all

    @courses = @courses.where(active: params[:active]) if params[:active].present?
    @courses = @courses.where(author_id: params[:author_id]) if params[:author_id].present?

    render_success_response(data: @courses)
  end

  def show
    render_success_response(data: @course)
  end

  def create
    @course = Course.new(course_params)

    if @course.save
      render_success_response(data: @course, message: 'Course created successfully')
    else
      render_failure_reponse(data: course_params, message: 'Course could not be created', errors: @course.errors)
    end
  end

  def update
    if @course.update(course_params)
      render_success_response(data: @course, message: 'Course updated successfully')
    else
      render_failure_reponse(data: course_params, message: 'Course could not be updated', errors: @course.errors)
    end
  end

  def destroy
    if @course.destroy
      render_success_response(data: @course, message: 'Course destroyed successfully')
    else
      render_failure_reponse(data: nil, message: 'Course could not be destroyed', errors: @course.errors)
    end
  end

  private

  def find_course
    @course = Course.find_by(id: params[:id])

    render_failure_reponse(message: 'Course not found', errors: ['Course not found'], status_code: '404') unless @course
  end

  def course_params
    params.require(:course).permit(:title, :description, :language, :active, :author_id)
  end
end
