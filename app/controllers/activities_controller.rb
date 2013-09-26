class ActivitiesController < ApplicationController
  before_filter :ensure_logged_in

  def index
    guardian.ensure_can_see!(Activity)
    activities = Activity.logged_after(params)
    serializer = params[:detailed] == 'true' ? ActivityDetailedSerializer : ActivitySerializer
    respond_to do |format|
      format.json { render_serialized(activities.to_a, serializer, root: 'activities') }
    end
  end
end
