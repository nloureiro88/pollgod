class PollsController < ApplicationController
  before_action :set_poll, only: %i(show add_answer result report toggle destroy)
  before_action :active_categories, only: %i(index manage answered sponsored fresh loved funny interesting)

  # Listing of polls

  def index
    @polls = select_polls.order('t_likes DESC, deadline ASC')
  end

  def fresh
    @polls = select_polls.order('created_at DESC, deadline ASC')
  end

  def loved
    @polls = select_polls.order('t_love DESC, deadline ASC')
  end

  def funny
    @polls = select_polls.order('t_funny DESC, deadline ASC')
  end

  def interesting
    @polls = select_polls.order('t_interest DESC, deadline ASC')
  end

  def sponsored
    @polls = select_polls.where(qtype: "sponsored").order('points DESC, deadline ASC')
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

  def report
  end

  # Poll inactivation

  def toggle
    if @poll.status == 'active'
      @poll.status = 'inactive'
    elsif @poll.status == 'inactive'
      @poll.status = 'active'
    end
    @poll.save!
    redirect_to({ controller: 'polls', action: params[:origin_action] })
  end

  def destroy
    @poll.answers.destroy_all
    @poll.destroy
    redirect_to({ controller: 'polls', action: params[:origin_action] })
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

  def poll_params
    params.require(:poll).permit(:id)
  end
end
