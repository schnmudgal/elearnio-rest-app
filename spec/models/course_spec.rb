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
require 'rails_helper'

RSpec.describe Course, type: :model do
  describe 'CONSTANTS' do
    it { expect(Course::LANGUAGES).to match_array(%w[en de]) }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:author) }
    it { is_expected.to have_many(:learning_paths_courses).dependent(:destroy) }
    it { is_expected.to have_many(:learning_paths).through(:learning_paths_courses) }
    it { is_expected.to have_many(:learning_paths_talents).through(:learning_paths).source(:talent) }
    it { is_expected.to have_many(:talents_courses).dependent(:destroy) }
    it { is_expected.to have_many(:direct_enrolled_talents).through(:talents_courses).source(:talent) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:language) }
    it { is_expected.to validate_inclusion_of(:language).in_array(Course::LANGUAGES) }
  end

  describe 'Scopes' do
    describe '.active' do
      let!(:active_course) { create :course, active: true }
      let!(:inactive_course) { create :course, active: false }

      it 'returns only active course' do
        expect(Course.active).to match_array([active_course])
      end
    end
  end
end
