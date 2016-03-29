class UserController < ApplicationController
  def activities
    params.permit(:id, :limit, :next_page_token)
    user_profile_feed_model = UserProfileFeed.new(id: params[:id], next_page_token: params[:next_page_token])
    @user_profile_feeds = user_profile_feed_model.feeds(params[:limit] || 10)
    @next_page_token = user_profile_feed_model.next_page_token
    render template: 'users/index'
  end

  def new_activity
    params.permit(:id, :content, :object)
    @activity = RailsNewsfeed::Activity.create(content: params[:content], object: params[:object])
    user_profile_feed_model = UserProfileFeed.new(id: params[:id])
    user_profile_feed_model.insert(@activity)
    render template: 'users/new_activity'
  end

  def hide_activity
    params.permit(:id, :activity_id)
    UserProfileFeed.delete(params[:id], params[:activity_id], false)
    render nothing: true
  end

  def new_related
    params.permit(:id, :related_id)
    user_a_profile_feed_model = UserProfileFeed.new(id: params[:id])
    user_b_profile_feed_model = UserProfileFeed.new(id: params[:related_id])
    user_a_profile_feed_model.register(user_b_profile_feed_model)
    render nothing: true
  end

  def remove_related
    params.permit(:id, :related_id)
    user_a_profile_feed_model = UserProfileFeed.new(id: params[:id])
    user_b_profile_feed_model = UserProfileFeed.new(id: params[:related_id])
    user_a_profile_feed_model.deregister(user_b_profile_feed_model)
    render nothing: true
  end
end
