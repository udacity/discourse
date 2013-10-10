# encoding: utf-8

require 'spec_helper'

describe Activity do
  it { should validate_presence_of :action }
  it { should validate_presence_of :user_id }
  it { should validate_presence_of :trackable_id }
  it { should validate_presence_of :trackable_type }
  it { should belong_to :user}
  it { should belong_to :trackable }

  it "has a valid factory" do
    topic = create_topic
    post = create_post(topic: topic)
    Fabricate(:activity, trackable: post, user: post.user).should be_valid
  end

  it "has a no argument valid factory" do
    create_activity().should be_valid
  end

  it "is invalid without action" do
    a = create_activity
    a.action = nil
    a.should_not be_valid
  end

  it "gets activities with id greater than the checkpoint" do
    a = create_activity()
    Activity.logged_after(offset: a.id-1).size.should == 1
  end

  it "gets user activities with id greater than the checkpoint" do
    a = create_activity()
    Activity.logged_after(offset: a.id-1, user_id: a.user_id).size.should == 1
  end
end
