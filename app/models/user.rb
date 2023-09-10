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
class User < ApplicationRecord

  # Validations
  validates :name, :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }, allow_blank: true

  # Public instance methods
  def as_author
    Author.find_by(id: id)
  end

  def as_talent
    Talent.find_by(id: id)
  end
end
