class ProfilesController < ApplicationController
  def dash
  end

  def go_premium
    user = current_user
    user.subscription = "premium"
    user.save!
    redirect_to({controller: 'profiles', action: 'dash'})
  end

  def go_pro
    user = current_user
    user.subscription = "pro"
    user.save!
    redirect_to({controller: 'profiles', action: 'dash'})
  end

  def filters
    @categories = Category.all
  end

  def filter_toggle
    target_category = Category.find(params[:cat_id])
    target_filter = Filter.find_by(user: current_user, category: target_category)
    if target_filter.nil?
      new_filter = Filter.new(user: current_user, category: target_category, active: false)
      new_filter.save!
    else
      target_filter.active = !target_filter.active
      target_filter.save!
    end

    if params[:origin_action].present? && params[:origin_action] != 'filters'
      redirect_to ({controller: 'polls', action: params[:origin_action], query: params[:query], friend_id: params[:friend_id]})
    else
      redirect_to :filters
    end
  end

  def filter_all
    Category.all.each do |category|
      filter = Filter.find_by(user: current_user, category: category)
      if filter.nil?
        new_filter = Filter.new(user: current_user, category: category, active: params[:active] == "true")
        new_filter.save!
      else
        filter.active = params[:active] == "true"
        filter.save!
      end
    end

    if params[:origin_action].present? && params[:origin_action] != 'filters'
      redirect_to ({controller: 'polls', action: params[:origin_action], query: params[:query], friend_id: params[:friend_id]})
    else
      redirect_to :filters
    end
  end
end
