class Api::V1::BaseController < ApplicationController
  before_action :authenticate_admin, only: [:create, :update, :destroy]

  private

  def authenticate_admin
    # TODO: Authenticate admin for admin only related tasks like Creating/Updating/Deleting resources
    ## but as mentioned in the task, that is out of the scope of this project
    ## thus just putting a dummy placeholder
  end

  def render_success_response(data:, message: nil, status_code: '200')
    render json: { data: data, message: message }, status: status_code
  end

  def render_failure_reponse(data: nil, message: 'Something went wrong!', errors: nil, status_code: '400')
    render json: { data: data, message: message, errors: errors }, status: status_code
  end
end
