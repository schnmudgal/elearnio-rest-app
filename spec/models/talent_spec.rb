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
require 'rails_helper'

RSpec.describe Talent, type: :model do
  describe 'Associations' do
    it { is_expected.to have_many(:talents_courses).dependent(:destroy) }
    it { is_expected.to have_many(:courses).through(:talents_courses) }
    it { is_expected.to have_many(:learning_paths).dependent(:destroy) }
    it { is_expected.to have_many(:learning_paths_courses).through(:learning_paths) }
  end
end
