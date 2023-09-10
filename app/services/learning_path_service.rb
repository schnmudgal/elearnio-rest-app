# frozen_string_literal: true

class LearningPathService

  # Sending learning_path_id instead of whole learning_path object
  ## so that method can used in a background service as well like sidekiq etc.
  def self.add_courses(learning_path_id, courses_data)
    learning_path, errors = find_learning_path(learning_path_id), []

    courses_data.each do |course_data|
      learning_paths_course = learning_path.learning_paths_courses.build(course_id: course_data[:course_id], position: course_data[:position])

      unless learning_paths_course.save
        errors << { data: course_data, errors: learning_paths_course.errors }
      end
    end

    return { success: errors.blank?, errors: errors }
  end

  # Sending learning_path_id instead of whole learning_path object
  ## so that method can used in a background service as well like sidekiq etc.
  def self.remove_courses(learning_path_id, course_ids)
    learning_path, errors = find_learning_path(learning_path_id), []
    current_position_before_delete = learning_path.current_learning_paths_course.position

    learning_path.learning_paths_courses.where(course_id: course_ids).each do |learning_paths_course|
      unless learning_paths_course.destroy
        errors << { data: { course_id: course_id }, errors: learning_paths_course.errors }
      end
    end

    # TO-NOTICE:
    # Even when "current_course" is deleted, then "acts_as_list" gem automatically updates the position of all remaing elements in list

    return { success: errors.blank?, errors: errors }
  end

  # private

  def self.find_learning_path(learning_path_id)
    learning_path = LearningPath.find_by(id: learning_path_id)

    raise "#{self.name}##{__callee__}: Learning path not found for id: #{learning_path_id}" unless learning_path

    return learning_path
  end
end
