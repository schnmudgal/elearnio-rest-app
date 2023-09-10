Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :show, :create, :update, :destroy] do
        member do
          get :my_learning_paths
          get :my_enrolled_courses
          get :my_authored_courses
        end
      end

      resources :courses, only: [:index, :show, :create, :update, :destroy]

      resources :learning_paths, only: [:index, :show, :create, :update, :destroy] do
        member do
          post :add_courses
          post :remove_courses
          post :start_course
          post :pause_course
          post :complete_course
        end
      end

      resources :talents_courses, only: [:index, :create] do
        collection do
          # Added them as a "collection" here instead of "member" because:
          ## technically a member route should have ":id" param related to "talents_courses" for this resource,
          ## but it is a join/intermediate table, so its own ":id" does not signify something important when it comes to APIs
          post :start_course
          post :pause_course
          post :complete_course
          post :disenroll_course

          post :enroll, action: :create # alias route to #create action for better readability of the route
          post :disenroll, action: :disenroll_course # alias route to #disenroll_course action for better readability of the route
        end
      end
    end
  end
end
