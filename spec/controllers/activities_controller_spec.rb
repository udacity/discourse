require 'spec_helper'

describe ActivitiesController do
  it 'requires you to be logged in' do
    lambda { xhr :get, :index }.should raise_error(Discourse::NotLoggedIn)
  end

  it 'forbids non-staff to pull activities' do
    log_in
    Guardian.any_instance.expects(:can_see?).with(Activity, nil).returns(false)
    xhr :get, :index, offset: 0
    response.should be_forbidden
  end

  it 'allows staff to pull activities' do
    Guardian.any_instance.stubs(:is_staff?).returns(true)
    log_in
    xhr :get, :index, offset: 0
    response.should be_success
    JSON.parse(response.body)['activities'].should == []
  end

  context 'returns activities' do
    before do
      @user = log_in
      @post = Fabricate(:post, user: @user)
      @activity = Fabricate(:activity, trackable: @post)
      puts @activity.inspect
    end

    it 'without trackables' do
      Guardian.any_instance.stubs(:is_staff?).returns(true)
      xhr :get, :index, offset: @activity.id - 1
      response.should be_success
      activities = JSON.parse(response.body)['activities']
      activities.size.should == 1
      activity = activities.first
      ['user_id', 'action', 'trackable_id', 'trackable_type', 'version', 'key'].each do |key|
        activity.should have_key(key)
      end
      activity.should_not have_key('trackable')
    end

    it 'with trackables' do
      Guardian.any_instance.stubs(:is_staff?).returns(true)
      xhr :get, :index, offset: @activity.id - 1, detailed: 'true'
      response.should be_success
      activities = JSON.parse(response.body)['activities']
      activities.first.should have_key('trackable')
    end
  end
end
