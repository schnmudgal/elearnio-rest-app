# == Schema Information
#
# Table name: learning_paths
#
#  id               :bigint           not null, primary key
#  completed_at     :datetime
#  current_position :integer          default(1)
#  paused_at        :datetime
#  progress_status  :string           default("enrolled"), not null
#  started_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  talent_id        :bigint           not null
#
# Indexes
#
#  index_learning_paths_on_talent_id  (talent_id)
#
# Foreign Keys
#
#  fk_rails_...  (talent_id => users.id)
#
FactoryBot.define do
  factory :learning_path do
    progress_status { 'enrolled' }
    talent
  end
end
