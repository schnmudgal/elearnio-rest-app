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
FactoryBot.define do
  factory :course do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    language { Course::LANGUAGES.sample }
    active { [true, false].sample }

    author
  end
end
