# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe ApiController do
  include Devise::TestHelpers
  before do
    sign_in User.new
    graph = Graph.new(:service => 'service', :section => 'section', :name => 'graph', :color => '#0000ff')
    graph.save
    @secret = graph.secret
    @now = Time.now
    Time.stub(:now){ @now }
  end

  def go_to_future(now,&block)
    t = @now
    @now += now
    block.call
    @now = t
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
      go_to_future(3.hours) do
        post :log, :service => 'service', :section => 'section', :graph => 'graph', :secret => @secret, :number => 2
      end
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

    describe "precision" do
      before {
        Log.delete_all
        ENV['HOSHI_MI_REALTIME'] =  '1'
        post :log, :service => 'service', :section => 'section', :graph => 'graph', :secret => @secret, :number => 1
        go_to_future(1.hour) do
          post :log, :service => 'service', :section => 'section', :graph => 'graph', :secret => @secret, :number => 2
        end
        ENV.delete 'HOSHI_MI_REALTIME'
      }

      subject {
        Graph.where(:service => 'service', :section => 'section').first
      }
      it {
        should have(2).logs
      }
    end
  end
end
