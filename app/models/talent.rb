# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  email      :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Talent < User

  # Associations
  has_many :talents_courses, dependent: :destroy
  has_many :courses, through: :talents_courses

  has_many :learning_paths, dependent: :destroy
  has_many :learning_paths_courses, through: :learning_paths, source: :courses
end
