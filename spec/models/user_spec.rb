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

RSpec.describe User, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
  end

  describe 'Public instance methods' do
    describe '#as_author' do
      let(:user) { create :user }

      it 'returns same record as an object of Author class' do
        expect(user.as_author.is_a?(Author)).to be(true)
        expect(user.as_author.id).to be(user.id)
      end
    end

    describe '#as_talent' do
      let(:user) { create :user }

      it 'returns same record as an object of Author class' do
        expect(user.as_talent.is_a?(Talent)).to be(true)
        expect(user.as_talent.id).to be(user.id)
      end
    end
  end
end
