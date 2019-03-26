class PollsController < ApplicationController
  before_action :set_poll, only: %i(show add_answer result toggle delete)
  before_action :active_categories, only: %i(index manage answered)

  # Listing of polls

  def index
    @polls = select_polls.order('t_likes DESC, deadline ASC')
  end

  def manage
    @polls = policy_scope(Poll).where("status != 'deleted' AND user_id = ? AND category_id IN (?)", current_user.id, @category_list).order('created_at DESC')
  end

  def answered
    polls_answered = Answer.where("status != 'deleted' AND user_id = ?", current_user.id).order('created_at DESC').pluck(:poll_id)
    @polls = polls_answered.map { |id| Poll.find(id) }.select{ |poll| @category_list.include?(poll.category_id) }
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

  def select_polls
    polls_answered = Answer.where("status != 'deleted' AND user_id = ?", current_user.id).pluck(:poll_id)
    polls_fetch = policy_scope(Poll).where("status = 'active' AND user_id != ? AND deadline > ? AND category_id IN (?)", current_user.id, Time.now, @category_list)
    polls_selection = polls_fetch.where("id NOT IN (?)", polls_answered)
    polls_selection
  end

  def active_categories
    @category_list = []
    Category.all.each do |cat|
      @category_list << cat.id if Filter.find_by(category: cat, user: current_user).active || Filter.find_by(category: cat, user: current_user).nil?
    end
  end

  def set_poll
    @poll = Poll.find(params[:id])
  end

end
