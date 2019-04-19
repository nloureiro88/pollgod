class PollsController < ApplicationController
  before_action :set_poll, only: %i(show add_answer result report toggle destroy)
  before_action :active_categories, only: %i(index manage answered sponsored fresh loved funny interesting friend)
  before_action :quick_links, only: %i(index manage answered sponsored fresh loved funny interesting friend)

  # Listing of polls

  def index
    polls = select_polls.order('t_likes DESC, deadline ASC')
    @polls = params[:query].present? ? polls.poll_search(params[:query]) : polls
  end

  def fresh
    polls = select_polls.order('created_at DESC, deadline ASC')
    @polls = params[:query].present? ? polls.poll_search(params[:query]) : polls
  end

  def loved
    polls = select_polls.order('t_love DESC, deadline ASC')
    @polls = params[:query].present? ? polls.poll_search(params[:query]) : polls
  end

  def funny
    polls = select_polls.order('t_funny DESC, deadline ASC')
    @polls = params[:query].present? ? polls.poll_search(params[:query]) : polls
  end

  def interesting
    polls = select_polls.order('t_interest DESC, deadline ASC')
    @polls = params[:query].present? ? polls.poll_search(params[:query]) : polls
  end

  def sponsored
    polls = select_polls.where(qtype: "sponsored").order('points DESC, deadline ASC')
    @polls = params[:query].present? ? polls.poll_search(params[:query]) : polls
  end

  def manage
    polls = policy_scope(Poll).where("status != 'deleted' AND user_id = ? AND category_id IN (?)", current_user.id, @category_list).order('created_at DESC')
    @polls = params[:query].present? ? polls.poll_search(params[:query]) : polls
  end

  def answered
    # polls_answered_ids = Answer.where("status != 'deleted' AND user_id = ?", current_user.id).order('created_at DESC').pluck(:poll_id)
    # polls_answered = Poll.where('id IN (?) AND category_id IN (?)', polls_answered_ids, @category_list)

    polls_answered = Poll.joins('INNER JOIN answers ON polls.id = answers.poll_id')
                         .where('category_id IN (?) AND answers.status != ? AND answers.user_id = ?',
                          @category_list, 'deleted', current_user.id)
                         .order('answers.created_at DESC')
    @polls = params[:query].present? ? polls_answered.poll_search(params[:query]) : polls_answered
  end

  def friend
    polls = policy_scope(Poll).where("status = 'active' AND user_id = ? AND category_id IN (?)", params[:friend_id].to_i, @category_list).order('created_at DESC')
    @polls = params[:query].present? ? polls.poll_search(params[:query]) : polls
  end

  # Poll creation

  def new
    authorize Poll
    @poll = Poll.new()
  end

  def create
    authorize Poll
    question = params["np-question"].last == "?" ? params["np-question"].sub(/\S/, &:upcase) : params["np-question"].sub(/\S/, &:upcase) + "?"
    @poll = Poll.new(user: current_user,
                    category_id: params["np-category"].to_i,
                    points: params["np-tickets"].to_i,
                    qtype: params["np-qtype"],
                    question: question,
                    optype: "SCP",
                    options: [params["np-opt-1"].sub(/\S/, &:upcase),
                              params["np-opt-2"].sub(/\S/, &:upcase),
                              params["np-opt-3"].sub(/\S/, &:upcase),
                              params["np-opt-4"].sub(/\S/, &:upcase),
                              params["np-opt-5"].sub(/\S/, &:upcase)]
                              .reject! { |s| s.nil? || s.strip.empty? },
                    tags: params["np-tags"].gsub(/, /, ",").split(",").each { |t| t.sub(/\S/, &:upcase) },
                    deadline: Time.parse(params["np-deadline"]))
    if @poll.save
      redirect_to manage_polls_path
    else
      render :new
    end
  end

  # Poll detail

  def show
    authorize Poll
  end

  # Poll answer workflow

  def add_answer
    if params["poll-id-#{@poll.id}"].present?
      new_answer = Answer.new(user: current_user,
                              poll: @poll,
                              points: @poll.points,
                              answer: params["poll-id-#{@poll.id}"],
                              f_love: params["icon-love-#{@poll.id}"] == "on",
                              f_funny: params["icon-funny-#{@poll.id}"] == "on",
                              f_interest: params["icon-interesting-#{@poll.id}"] == "on")
      new_answer.save!
      @poll.refresh_likes
    else
      flash[:alert] = "No valid answer selected for the poll."
    end
  end

  def result
    @results = @poll.results
    @answer = @poll.answer(current_user)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def report
    new_report = Report.new(user: current_user, poll: @poll)
    new_report.save!
    redirect_to(controller: 'polls', action: params[:origin_action])
  end

  # Poll inactivation

  def toggle
    if @poll.status == 'active'
      @poll.status = 'inactive'
    elsif @poll.status == 'inactive'
      @poll.status = 'active'
    end
    @poll.save!
    redirect_to(controller: 'polls', action: params[:origin_action])
  end

  def destroy
    @poll.answers.destroy_all
    @poll.destroy
    redirect_to(controller: 'polls', action: params[:origin_action])
  end

  private

  def select_polls
    polls_answered = Answer.where("status != 'deleted' AND user_id = ?", current_user.id).pluck(:poll_id)
    polls_reported = Report.where("status != 'deleted' AND user_id = ?", current_user.id).pluck(:poll_id)
    polls_fetch = policy_scope(Poll).where("status = 'active' AND user_id != ? AND deadline > ? AND category_id IN (?)", current_user.id, Time.now, @category_list)
    polls_selection = polls_answered.size.zero? ? polls_fetch : polls_fetch.where("id NOT IN (?)", polls_answered)
    polls = polls_reported.size.zero? ? polls_selection : polls_selection.where("id NOT IN (?)", polls_reported)
  end

  def active_categories
    @category_list = []
    Category.all.each do |cat|
      filter = Filter.find_by(category: cat, user: current_user)
      @category_list << cat.id if filter.nil? || filter.active
    end
  end

  def quick_links
    return if current_user.nil?

    @quick_links = current_user.hobbies.empty? ? [] : current_user.hobbies.split(", ").map { |hob| hob.downcase.capitalize }
    all_tags = Poll.where('status = ? AND deadline > ?', 'active', Time.now).pluck(:tags).flatten
    hot_tags = Hash.new(0)
    all_tags.each { |tag| hot_tags[tag.downcase.capitalize] += 1 }
    hot_tags.sort_by { |_tag, value| value }.each { |tag, _value| @quick_links << tag }
    @quick_links
  end

  def set_poll
    @poll = Poll.find(params[:id])
  end

  def poll_params
    params.require(:poll).permit(:id)
  end
end
