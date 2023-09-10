# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

# Seed Users Data
puts '-----------------------------------------------------'
puts '---------------> Seeding Users'
users_array = [
  { name: 'First User', email: 'first@example.com' },
  { name: 'Second User', email: 'second@example.com' },
  { name: 'Third User', email: 'third@example.com' },
  { name: 'Fourth User', email: 'fourth@example.com' }
]

users_array.each do |users_data|
  User.where(email: users_data[:email]).first_or_create(name: users_data[:name])
end


# Seed Courses Data
puts '-----------------------------------------------------'
puts '---------------> Seeding Courses'
first_author = Author.first
second_author = Author.second
third_talent = Talent.third
fourth_talent = Talent.fourth

courses_array = [
  { title: 'First Course', description: 'First Course Description', author: first_author },
  { title: 'Second Course', description: 'Second Course Description', author: first_author },
  { title: 'Third Course', description: 'Third Course Description', author: second_author },
  { title: 'Fourth Course', description: 'Fourth Course Description', author: second_author }
]

courses_array.each do |course_data|
  Course.where(title: course_data[:title]).first_or_create(
    description: course_data[:description],
    author: course_data[:author]
  )
end

first_course = Course.first
second_course = Course.second
third_course = Course.third
fourth_course = Course.fourth


# Seed Talents Course Data
puts '-----------------------------------------------------'
puts '---------------> Seeding Talents Courses'
talents_courses_array = [
  { talent: third_talent, course: first_course },
  { talent: third_talent, course: second_course },
  { talent: fourth_talent, course: third_course },
  { talent: fourth_talent, course: fourth_course },
]

talents_courses_array.each do |talents_course_data|
  TalentsCourse.create(talents_course_data)
end


# Seed Learning Paths Data
puts '-----------------------------------------------------'
puts '---------------> Seeding Learning Paths'
learning_paths_array = [
  {
    talent: third_talent,
    learning_paths_courses_attributes: [
      { course_id: first_course.id, position: 1 },
      { course_id: third_course.id, position: 2 },
    ]
  },
  {
    talent: fourth_talent,
    learning_paths_courses_attributes: [
      { course_id: second_course.id, position: 1 },
      { course_id: fourth_course.id, position: 2 },
    ]
  },
  {
    talent: third_talent,
    learning_paths_courses_attributes: [
      { course_id: first_course.id, position: 1 },
      { course_id: second_course.id, position: 2 },
      { course_id: third_course.id, position: 3 },
      { course_id: fourth_course.id, position: 4 },
    ]
  },
]

learning_paths_array.each do |learning_path_data|
  LearningPath.create(learning_path_data)
end
