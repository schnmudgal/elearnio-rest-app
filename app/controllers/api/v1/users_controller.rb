class Api::V1::UsersController < Api::V1::BaseController
  before_action :find_user, only: [
    :show, :update, :destroy,
    :my_authored_courses, :my_learning_paths, :my_enrolled_courses
  ]

  def index
    @users = User.all

    render_success_response(data: @users)
  end

  def show
    render_success_response(data: @user)
  end

  def create
    @user = User.new(user_params)

    if @user.save
      render_success_response(data: @user, message: 'User created successfully')
    else
      render_failure_reponse(data: user_params, message: 'User could not be created', errors: @user.errors)
    end
  end

  def update
    if @user.update(user_params)
      render_success_response(data: @user, message: 'User updated successfully')
    else
      render_failure_reponse(data: user_params, message: 'User could not be updated', errors: @user.errors)
    end
  end

  def destroy
    @author = @user.as_author
    @author.substitute_author_id = params[:new_author_id]

    if @author.destroy
      render_success_response(data: @user, message: 'User destroyed successfully')
    else
      render_failure_reponse(data: nil, message: 'User could not be destroyed', errors: @author.errors)
    end
  end

  def my_learning_paths
    render_success_response(
      data: @user.as_talent.learning_paths.includes(:learning_paths_courses, :courses).as_json(
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

  def my_enrolled_courses
    render_success_response(data: @user.as_talent.talents_courses.includes(:course).as_json(
      only: [:id, :progress_status],
      include: [
        { course: { only: [:id, :language, :title] } }
      ]
    ))
  end

  def my_authored_courses
    render_success_response(data: @user.as_author.courses)
  end

  private

  def find_user
    @user = User.find_by(id: params[:id])

    render_failure_reponse(message: 'User not found', errors: ['User not found'], status_code: '404') unless @user
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
