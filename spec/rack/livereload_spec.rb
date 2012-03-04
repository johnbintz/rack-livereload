require 'spec_helper'

describe Rack::LiveReload do
  let(:middleware) { described_class.new(app, options) }
  let(:app) { stub }

  subject { middleware }

  its(:app) { should == app }

  let(:env) { {} }
  let(:options) { {} }

  describe described_class::LIVERELOAD_LOCAL_URI do
    context 'does not exist' do
      before do
        stub_request(:any, 'localhost:35729/livereload.js').to_timeout
      end

      it { should use_vendored }
    end

    context 'exists' do
      before do
        stub_request(:any, 'localhost:35729/livereload.js')
      end

      it { should_not use_vendored }
    end

    context 'specify vendored' do
      let(:options) { { :source => :vendored } }

      it { should use_vendored }
    end

    context 'specify LR' do
      let(:options) { { :source => :livereload } }

      it { should_not use_vendored }
    end
  end

  context 'not text/html' do
    let(:ret) { [ 200, { 'Content-Type' => 'image/png' }, [ '<head></head>' ] ] }

    before do
      app.stubs(:call).with(env).returns(ret)
    end

    it 'should pass through' do
      middleware.call(env).should == ret
    end
  end

  context 'unknown Content-Type' do
    let(:ret) { [ 200, {}, [ 'hey ho' ] ] }

    before do
      app.stubs(:call).with(env).returns(ret)
    end

    it 'should not break' do
      middleware.call(env).should_not raise_error(NoMethodError, /You have a nil object/)
    end
  end

  context 'text/html' do
    before do
      app.stubs(:call).with(env).returns([ 200, { 'Content-Type' => 'text/html', 'Content-Length' => 0 }, [ '<head></head>' ] ])
      middleware.stubs(:use_vendored?).returns(true)
    end

    let(:host) { 'host' }
    let(:env) { { 'HTTP_HOST' => host } }

    let(:ret) { middleware._call(env) }
    let(:body) { ret.last.join }
    let(:length) { ret[1]['Content-Length'] }

    context 'vendored' do
      it 'should add the vendored livereload js script tag' do
        body.should include("script")
        body.should include(described_class::LIVERELOAD_JS_PATH)

        length.should == body.length.to_s

        described_class::LIVERELOAD_JS_PATH.should_not include(host)

        body.should include('swfobject')
        body.should include('web_socket')
      end
    end

    context 'not vendored' do
      before do
        middleware.stubs(:use_vendored?).returns(false)
      end

      it 'should add the LR livereload js script tag' do
        body.should include("script")
        body.should include(described_class::LIVERELOAD_LOCAL_URI.gsub('localhost', 'host'))
      end
    end

    context 'set options' do
      let(:middleware) { described_class.new(app, :host => new_host, :port => port, :min_delay => min_delay, :max_delay => max_delay) }
      let(:min_delay) { 5 }
      let(:max_delay) { 10 }
      let(:port) { 23 }
      let(:new_host) { 'myhost' }

      it 'should add the livereload.js script tag' do
        body.should include("mindelay=#{min_delay}")
        body.should include("maxdelay=#{max_delay}")
        body.should include("port=#{port}")
        body.should include("host=#{new_host}")
      end
    end

    context 'force flash' do
      let(:middleware) { described_class.new(app, :force_swf => true) }

      it 'should not add the flash shim' do
        body.should include('WEB_SOCKET_FORCE_FLASH')
        body.should include('swfobject')
        body.should include('web_socket')
      end
    end

    context 'no flash' do
      let(:middleware) { described_class.new(app, :no_swf => true) }

      it 'should not add the flash shim' do
        body.should_not include('swfobject')
        body.should_not include('web_socket')
      end
    end

    context 'no host at all' do
      let(:env) { {} }

      it 'should use localhost' do
        body.should include('localhost')
      end
    end

    context 'ignored' do
      let(:options) { { :ignore => [ %r{file} ] } }

      context 'not root' do
        let(:env) { { 'PATH_INFO' => '/this/file' } }

        it 'should have no change' do
          body.should_not include('script')
        end
      end

      context 'root' do
        let(:env) { { 'PATH_INFO' => '/' } }

        it 'should have script' do
          body.should include('script')
        end
      end
    end
  end

  context '/__rack/livereload.js' do
    let(:env) { { 'PATH_INFO' => described_class::LIVERELOAD_JS_PATH } }

    before do
      middleware.expects(:deliver_file).returns(true)
    end

    it 'should return the js file' do
      middleware._call(env).should be_true
    end
  end

  describe '#ignored?' do
    let(:path_info) { 'path info' }

    context 'no ignore set' do
      it { should_not be_ignored(path_info) }
    end

    context 'ignore set' do
      let(:options) { { :ignore => [ %r{#{path_info}} ] } }

      it { should be_ignored(path_info) }
    end
  end

  describe '#bad_browser?' do
    let(:user_agent) { described_class::BAD_USER_AGENTS.first.source }

    it { should be_bad_browser(user_agent) }
  end
end

