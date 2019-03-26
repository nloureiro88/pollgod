class PollsController < ApplicationController
  before_action :set_poll, only: %i(show add_answer result toggle delete)

  # Listing of polls

  def index
    @polls = policy_scope(Poll).where("status = 'active' AND user_id != ? AND deadline > ?", current_user.id, Time.now)
  end

  def management
    @polls = policy_scope(Poll).where("status != 'deleted' AND user_id = ?", current_user.id)
  end

  def show_answers #WIP
    @polls = policy_scope(Poll).where("status = 'active' AND user_id != ?", current_user.id)
  end

  # Poll creation

  def new
  end

  def create
  end

  # Poll detail

  def show
  end

  # Poll answer workflow

  def add_answer
  end

  def result
  end

  # Poll inactivation

  def toggle
  end

  def delete
  end

 private

  def set_poll
    @poll = Poll.find(params[:id])
  end

end
