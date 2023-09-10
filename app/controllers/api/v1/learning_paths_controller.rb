class Api::V1::LearningPathsController < Api::V1::BaseController
  before_action :find_learning_path, only: [:show, :update, :destroy, :add_courses, :remove_courses, :start_course, :pause_course, :complete_course]
  before_action :find_learning_paths_course, only: [:start_course, :pause_course, :complete_course]

  def index
    @learning_paths = LearningPath.all

    @learning_paths = @learning_paths.having_progress_statuses(params[:progress_status]) if params[:progress_status].present?
    @learning_paths = @learning_paths.of_talent(params[:talent_id]) if params[:talent_id].present?

    render_success_response(
      data: @learning_paths.includes(:learning_paths_courses, :courses).as_json(learning_path_json_response_attributes)
    )
  end

  def show
    render_success_response(data: @learning_path.as_json(learning_path_json_response_attributes))
  end

  def create
    @learning_path = LearningPath.new(learning_path_params)

    if @learning_path.save
      render_success_response(data: @learning_path, message: 'Learning Path created successfully')
    else
      render_failure_reponse(data: learning_path_params, message: 'Learning Path could not be created', errors: @learning_path.errors)
    end
  end

  def update
    if @learning_path.update(learning_path_params)
      render_success_response(data: @learning_path.as_json(include: :learning_paths_courses), message: 'Learning Path updated successfully')
    else
      render_failure_reponse(data: learning_path_params, message: 'Learning Path could not be updated', errors: @learning_path.errors)
    end
  end

  def destroy
    if @learning_path.destroy
      render_success_response(data: @learning_path, message: 'Learning Path destroyed successfully')
    else
      render_failure_reponse(data: nil, message: 'Learning Path could not be destroyed', errors: @learning_path.errors)
    end
  end

  def add_courses
    learning_paths_courses_data = add_courses_params[:learning_paths_courses_attributes]
    result = LearningPathService.add_courses(@learning_path.id, learning_paths_courses_data)

    if result[:errors].blank?
      render_success_response(data: @learning_path.reload.as_json(learning_path_json_response_attributes), message: 'Courses added successfully')
    else
      render_failure_reponse(data: nil, message: 'Some courses could not be added', errors: result[:errors])
    end
  end

  def remove_courses
    result = LearningPathService.remove_courses(@learning_path.id, params[:course_ids])

    if result[:errors].blank?
      render_success_response(data: @learning_path.reload.as_json(learning_path_json_response_attributes), message: 'Courses deleted successfully')
    else
      render_failure_reponse(data: nil, message: 'Some courses could not be deleted', errors: result[:errors])
    end
  end

  def start_course
    if @learning_paths_course.start!
      render_success_response(data: nil, message: 'Course started successfully')
    else
      render_failure_reponse(data: nil, errors: @learning_paths_course.errors)
    end
  end

  def pause_course
    if @learning_paths_course.pause!
      render_success_response(data: nil, message: 'Course paused successfully')
    else
      render_failure_reponse(data: nil, errors: @learning_paths_course.errors)
    end
  end

  def complete_course
    if @learning_paths_course.complete!
      render_success_response(data: nil, message: 'Course completed successfully')
    else
      render_failure_reponse(data: nil, errors: @learning_paths_course.errors)
    end
  end

  private

  def find_learning_path
    @learning_path = LearningPath.find_by(id: params[:id])

    render_failure_reponse(message: 'Learning Path not found', errors: ['Learning Path not found'], status_code: '404') unless @learning_path
  end

  def find_learning_paths_course
    @learning_paths_course = @learning_path.learning_paths_courses.find_by(course_id: params[:course_id])

    render_failure_reponse(
      message: 'Course not found in this Learning Path', errors: ['Course not found in this Learning Path'], status_code: '404'
    ) unless @learning_paths_course
  end

  def learning_path_params
    params.require(:learning_path).permit(
      :activity_status, :progress_status, :talent_id, :current_position,
      learning_paths_courses_attributes: [:id, :course_id, :position, :_destroy]
    )
  end

  def add_courses_params
    params.require(:learning_path).permit(learning_paths_courses_attributes: [:course_id, :position])
  end

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
end
