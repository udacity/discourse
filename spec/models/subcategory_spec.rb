# encoding: utf-8

require 'spec_helper'

describe Subcategory do
  it { should validate_presence_of :user_id }
  it { should validate_presence_of :name }
  it { should belong_to :category }
  it { should belong_to :user }
end
