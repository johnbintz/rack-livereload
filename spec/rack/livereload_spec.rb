require 'spec_helper'

describe Rack::LiveReload do
  let(:middleware) { described_class.new(app) }
  let(:app) { stub }

  subject { middleware }

  its(:app) { should == app }

  let(:env) { {} }

  context 'not text/html' do
    let(:ret) { [ 200, { 'Content-Type' => 'image/png' }, [ '<head></head>' ] ] }

    before do
      app.stubs(:call).with(env).returns(ret)
    end

    it 'should pass through' do
      middleware.call(env).should == ret
    end
  end

  context 'text/html' do
    before do
      app.stubs(:call).with(env).returns([ 200, { 'Content-Type' => 'text/html', 'Content-Length' => 0 }, [ '<head></head>' ] ])
    end

    let(:ret) { middleware.call(env) }
    let(:body) { ret.last.join }
    let(:length) { ret[1]['Content-Length'] }

    it 'should add the livereload js script tag' do
      body.should include("script")
      body.should include(described_class::LIVERELOAD_JS_PATH)

      length.should == body.length.to_s
    end
  end

  context '/__rack/livereload.js' do
    let(:env) { { 'PATH_INFO' => described_class::LIVERELOAD_JS_PATH } }

    before do
      middleware.expects(:deliver_file).returns(true)
    end

    it 'should return the js file' do
      middleware.call(env).should be_true
    end
  end
end
