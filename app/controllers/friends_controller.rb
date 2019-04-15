class FriendsController < ApplicationController

  def index
    friend_rs = Friend.where(active_user_id: current_user.id, status: 'active')
    @friends = friend_rs.map { |rs| User.find(rs.follow_user_id) }.sort_by { |fr| fr.last_name }
  end

  def add
    authorize Friend
    friend_id = params[:friend_id]
    rs = Friend.where(active_user_id: current_user.id, follow_user_id: friend_id)
    if rs.empty?
      Friend.create(active_user_id: current_user.id, follow_user_id: friend_id, status: 'active')
    else
      rel = rs.last
      rel.status = 'active'
      rel.save!
    end

    redirect_to friends_path
  end

  def remove
    authorize Friend
    friend_id = params[:friend_id]
    rs = Friend.where(active_user_id: current_user.id, follow_user_id: friend_id).last
    rs.status = 'inactive'
    rs.save!

    redirect_to friends_path
  end

  private

  def friend_params
    params.require(:friend).permit(:id)
  end
end
