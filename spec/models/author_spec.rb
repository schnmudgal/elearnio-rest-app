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

RSpec.describe Author, type: :model do
  describe 'Attr accessors' do
    it { is_expected.to respond_to(:substitute_author_id) }
    it { is_expected.to respond_to(:substitute_author_id=) }
  end

  describe 'Associations' do
    it { is_expected.to have_many(:courses) }
  end

  describe 'Public instance methods' do

    describe '#has_courses?' do
      let(:author) { create :author }

      context 'when author does NOT have associated courses' do
        it 'returns false' do
          expect(author.has_courses?).to be(false)
        end
      end

      context 'when author has associated courses' do
        let!(:course_1) { create :course, author: author }
        let!(:course_2) { create :course, author: author }

        it 'returns true' do
          expect(author.has_courses?).to be(true)
        end
      end
    end
  end

  describe 'Callbacks' do

    describe 'before_destroy: #transfer_my_courses' do
      let!(:author) { create :author }

      context 'when author does NOT have associated courses' do
        it 'deletes the author' do
          expect{ author.destroy }.to change{ Author.count }.by(-1)
        end
      end

      context 'when author has associated courses' do
        let!(:course_1) { create :course, author: author }
        let!(:course_2) { create :course, author: author }

        context 'when substitued author does NOT exist' do
          before { author.substitute_author_id = 0 }

          it 'does NOT delete the author' do
            expect{ author.destroy }.not_to change{ Author.count }
          end

          it 'adds error related to substituted author' do
            author.destroy
            expect(author.errors[:base]).to include('Substitute author not found')
          end

          it 'does NOT transfer existing courses' do
            author.destroy

            expect(course_1.reload.author_id).to eq(author.id)
            expect(course_2.reload.author_id).to eq(author.id)
          end
        end

        context 'when substitued author exists' do
          let(:author_2) { create :author }

          before { author.substitute_author_id = author_2.id }

          it 'deletes the author' do
            expect{ author.destroy }.to change{ Author.count }.by(-1)
          end

          it 'transfers existing courses to the new author' do
            author.destroy

            expect(course_1.reload.author_id).to eq(author_2.id)
            expect(course_2.reload.author_id).to eq(author_2.id)
          end
        end
      end
    end
  end
end
