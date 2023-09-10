require 'rails_helper'

shared_examples_for 'progress_status_actionable' do
  let(:model) { described_class }
  let(:factory_name) { model.to_s.underscore.to_sym }

  describe 'CONSTANTS' do
    it { expect(model::PROGRESS_STATUSES_HASH).to eq({
      enrolled: 'enrolled',
      in_progress: 'in_progress',
      paused: 'paused',
      completed: 'completed'
    }) }
    it { expect(model::PROGRESS_STATUSES).to match_array(%w[enrolled in_progress paused completed]) }
  end

  describe 'Public instance methods' do
    let(:object) { create factory_name, progress_status: 'enrolled' }

    describe '#start!' do
      it "updates the progress_status to 'in_progress'" do
        object.start!
        expect(object.progress_status).to eq('in_progress')
        expect(object.started_at).not_to be_blank
      end
    end

    describe '#pause!' do
      it "updates the progress_status to 'paused'" do
        object.pause!
        expect(object.progress_status).to eq('paused')
        expect(object.paused_at).not_to be_blank
      end
    end

    describe '#complete!' do
      it "updates the progress_status to 'completed'" do
        object.complete!
        expect(object.progress_status).to eq('completed')
        expect(object.completed_at).not_to be_blank
      end
    end
  end

end
