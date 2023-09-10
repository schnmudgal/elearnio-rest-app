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
class Author < User

  # Attr accessors
  attr_accessor :substitute_author_id

  # Associations
  has_many :courses

  ## associations below are related to talents, but are still need to destroy dependent children when we call author.destroy
  has_many :talents_courses, foreign_key: :talent_id, dependent: :destroy
  has_many :learning_paths, foreign_key: :talent_id, dependent: :destroy

  # Callbacks
  before_destroy :transfer_my_courses


  # Public instance methods
  def has_courses?
    courses.present?
  end

  # Private instance methods
  private

  def transfer_my_courses
    return unless has_courses?

    substitute_author = Author.find_by(id: substitute_author_id)
    errors.add(:base, 'Substitute author not found') and throw(:abort) unless substitute_author

    courses.update_all(author_id: substitute_author_id)
  end
end
