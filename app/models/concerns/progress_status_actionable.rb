module ProgressStatusActionable
  extend ActiveSupport::Concern

  # CONSTANTS
  PROGRESS_STATUSES_HASH = {
    enrolled: 'enrolled',
    in_progress: 'in_progress',
    paused: 'paused',
    completed: 'completed'
  }.freeze

  PROGRESS_STATUSES = PROGRESS_STATUSES_HASH.values.freeze

  def start!
    update(progress_status: PROGRESS_STATUSES_HASH[:in_progress], started_at: Time.current)
  end

  alias_method :mark_in_progress!, :start!

  def pause!
    update(progress_status: PROGRESS_STATUSES_HASH[:paused], paused_at: Time.current)
  end

  alias_method :mark_paused!, :pause!

  def complete!
    update(progress_status: PROGRESS_STATUSES_HASH[:completed], completed_at: Time.current)
  end

  alias_method :mark_completed!, :complete!
end
