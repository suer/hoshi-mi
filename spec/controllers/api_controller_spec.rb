# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe ApiController do
  include Devise::TestHelpers
  before do
    sign_in User.new
    graph = Graph.new(:service => 'service', :section => 'section', :name => 'graph', :color => '#0000ff')
    graph.save
    @secret = graph.secret
  end

  context "post log" do
    before do
      post :log, :service => 'service', :section => 'section', :graph => 'graph', :secret => @secret, :number => 1
    end
    subject { response }
    it { should be_success }
  end

  context "post double-log" do
    before do
      post :log, :service => 'service', :section => 'section', :graph => 'graph', :secret => @secret, :number => 1
      post :log, :service => 'service', :section => 'section', :graph => 'graph', :secret => @secret, :number => 2
    end

    describe "response" do
      subject { response }
      it { should be_success }
    end

    describe "data" do
      subject {
        Graph.where(:service => 'service', :section => 'section').first
      }
      it {
        should have(1).logs
      }
    end
  end
end
