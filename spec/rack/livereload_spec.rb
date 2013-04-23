require 'spec_helper'
require 'nokogiri'

describe Rack::LiveReload do
  let(:middleware) { described_class.new(app, options) }
  let(:app) { stub }

  subject { middleware }

  its(:app) { should == app }

  let(:env) { {} }
  let(:options) { {} }

  context '/__rack/livereload.js' do
    let(:env) { { 'PATH_INFO' => described_class::BodyProcessor::LIVERELOAD_JS_PATH } }

    before do
      middleware.expects(:deliver_file).returns(true)
    end

    it 'should return the js file' do
      middleware._call(env).should be_true
    end
  end
end

