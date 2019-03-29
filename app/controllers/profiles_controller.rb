class ProfilesController < ApplicationController
  def dash
  end

  def filters
    @categories = Category.all
  end

  def filter_toggle
    target_category = Category.find(params[:cat_id])
    target_filter = Filter.find_by(user: current_user, category_id: target_category)
    if target_filter.nil?
      new_filter = Filter.new(user: current_user, category: target_category, active: false)
      new_filter.save!
    else
      target_filter.active = !target_filter.active
      target_filter.save!
    end

    if params[:origin_action].present? && params[:origin_action] != 'filters'
      redirect_to ({controller: 'polls', action: params[:origin_action], query: params[:query]})
    else
      redirect_to :filters
    end
  end
end
