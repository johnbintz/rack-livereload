require 'spec_helper'

describe Rack::LiveReload::ProcessingSkipAnalyzer do
  subject { described_class.new(result, env, options) }

  let(:result) { [ status, headers, body ] }
  let(:env) { { 'HTTP_USER_AGENT' => user_agent } }
  let(:options) { {} }

  let(:user_agent) { 'Firefox' }
  let(:status) { 200 }
  let(:headers) { {} }
  let(:body) { [] }

  describe '#skip_processing?' do
    it "should skip processing" do
      subject.skip_processing?.should be_true
    end
  end

  describe '#bad_browser?' do
    let(:user_agent) { described_class::BAD_USER_AGENTS.first.source }

    it { should be_bad_browser }
  end

  context 'ignored' do
    let(:options) { { :ignore => [ %r{file} ] } }

    context 'not root' do
      let(:env) { { 'PATH_INFO' => '/this/file' } }

      it { should be_ignored }
    end

    context 'root' do
      let(:env) { { 'PATH_INFO' => '/' } }

      it { should_not be_ignored }
    end
  end

  context 'not text/html' do
    let(:headers) { { 'Content-Type' => 'application/pdf' } }

    it { should_not be_html }
  end

  context 'chunked response' do
    let(:headers) { { 'Transfer-Encoding' => 'chunked' } }

    it { should be_chunked }
  end


  context 'inline disposition' do
    let(:headers) { { 'Content-Disposition' => 'inline; filename=my_inlined_file' } }

    it { should be_inline }
  end

  describe '#ignored?' do
    let(:path_info) { 'path info' }
    let(:env) { { 'PATH_INFO' => path_info } }

    context 'no ignore set' do
      it { should_not be_ignored }
    end

    context 'ignore set' do
      let(:options) { { :ignore => [ %r{#{path_info}} ] } }

      it { should be_ignored }
    end
  end
end

