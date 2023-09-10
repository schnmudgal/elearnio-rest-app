# frozen_string_literal: true

# == Schema Information
#
# Table name: courses
#
#  id          :bigint           not null, primary key
#  active      :boolean          default(FALSE), not null
#  description :string           not null
#  language    :string           default("en"), not null
#  title       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  author_id   :bigint           not null
#
# Indexes
#
#  index_courses_on_author_id  (author_id)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#
class Course < ApplicationRecord
  # CONSTANTS
  LANGUAGES = %w[en de].freeze

  # Associations
  belongs_to :author

  has_many :learning_paths_courses, dependent: :destroy
  has_many :learning_paths, through: :learning_paths_courses
  has_many :learning_paths_talents, through: :learning_paths, source: :talent

  has_many :talents_courses, dependent: :destroy
  has_many :direct_enrolled_talents, through: :talents_courses, source: :talent

  # Validations
  validates :title, :description, :language, presence: true
  validates :language, inclusion: { in: LANGUAGES }, allow_blank: true

  # Scopes
  scope :active, -> { where(active: true) }
end
