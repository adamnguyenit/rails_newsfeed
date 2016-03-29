class ActivityController < ApplicationController
  def remove_activity
    params.permit(:id)
    RailsNewsfeed::Activity.delete(id: params[:id])
    render nothing: true
  end
end
