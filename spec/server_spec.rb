# coding: utf-8

require 'spec_helper'
require './server.rb'

describe 'T001: Routing Test' do
  include Rack::Test::Methods

  # Fake Codeforces Contests
  before do
    response_body = File.read(File.dirname(__FILE__) + "/mock/codeforces_com_contests_locale_en.html")
    stub_request(:get, 'http://codeforces.com/contests?locale=en').to_return({
      :status => 200,
      :headers => {
        'Content-Type' => 'text/html',
      },
      :body => response_body,
    })
  end

  # Fake Hatena Login
  before do
    stub_request(:get, 'https://www.hatena.ne.jp/login').to_return({
      :status => 200,
      :headers => {
        'Content-Type' => 'text/html',
      },
      :body => '<form action="/login" method="post"></form>',
    })
    stub_request(:post, 'https://www.hatena.ne.jp/login').to_return({
      :status => 200,
      :headers => {
        'Content-Type' => 'text/html',
      },
      :body => '<form action="/login" method="post"></form>',
    })
  end

  # Fake Hatena Group
  before do
    stub_request(:get, /https:\/\/group.g.hatena.ne.jp\/keyword\/.*/).to_return({
      :status => 200,
      :headers => {
        'Content-Type' => 'text/html',
      },
      :body => 'test',
    })
  end

  def app
    App.new
  end

  describe 'T001_001: POST /test' do
    before do
      post '/test', {"token" => "test"}
    end
    it 'T001_001_001: with valid token' do
      last_response.should be_ok
    end
  end

  describe 'T001_002: POST /test' do
    before do
      post '/test', {"token" => "test2"}
    end
    it 'T001_002_001: with invalid token' do
      last_response.should_not be_ok
    end
  end

  describe 'T001_003: POST /test' do
    before do
      post '/test', {"token" => "1test"}
    end
    it 'T001_003_001: with invalid token' do
      last_response.should_not be_ok
    end
  end

end

describe 'T002: Codeforces Parsing Test' do
  describe 'T002_001: Get contest list.1' do
    # Fake Codeforces Contests
    before do
      response_body = File.read(File.dirname(__FILE__) + "/mock/t002_001.html")
      stub_request(:get, 'http://codeforces.com/contests?locale=en').to_return({
        :status => 200,
        :headers => {
          'Content-Type' => 'text/html',
        },
        :body => response_body,
      })
    end

    it 'T002_001_001: Duplicate' do
      ret = test_get_contest_list_from_codeforces()
      ret.length.should == 3
    end

    it 'T002_001_002: Unique' do
      ret1 = test_get_contest_list_from_codeforces()
      ret1.length.should == 3
      ret2 = get_unique_contest_list(ret1)
      ret2.length.should == 2
    end
  end

  describe 'T002_002: Get contest list.2' do
    # Fake Codeforces Contests
    before do
      response_body = File.read(File.dirname(__FILE__) + "/mock/t002_002.html")
      stub_request(:get, 'http://codeforces.com/contests?locale=en').to_return({
        :status => 200,
        :headers => {
          'Content-Type' => 'text/html',
        },
        :body => response_body,
      })
    end

    it 'T002_002_001: Duplicate' do
      ret = test_get_contest_list_from_codeforces()
      ret.length.should == 4
    end

    it 'T002_002_002: Unique' do
      ret1 = test_get_contest_list_from_codeforces()
      ret1.length.should == 4
      ret2 = get_unique_contest_list(ret1)
      ret2.length.should == 3
    end
  end

  describe 'T002_003: Time Test.1' do
    # Fake Codeforces Contests
    before do
      response_body = File.read(File.dirname(__FILE__) + "/mock/t002_003.html")
      stub_request(:get, 'http://codeforces.com/contests?locale=en').to_return({
        :status => 200,
        :headers => {
          'Content-Type' => 'text/html',
        },
        :body => response_body,
      })
    end

    it 'T002_003_001: Check Time' do
      ret = test_get_contest_list_from_codeforces()
      ret[0]["date"].should eq DateTime.parse('2013-09-11T17:00JST')
      ret[1]["date"].should eq DateTime.parse('2013-09-11T17:00JST')
      ret[2]["date"].should eq DateTime.parse('2013-09-30T17:30JST')
      ret[3]["date"].should eq DateTime.parse('2013-09-30T17:45JST')
      ret[4]["date"].should eq DateTime.parse('2013-12-24T10:00JST')
      ret[5]["date"].should eq DateTime.parse('2013-12-25T00:00JST')
      ret[6]["date"].should eq DateTime.parse('2013-12-25T00:30JST')
    end
  end

  describe 'T002_004: Get Contest List(Running)' do
    # Fake Codeforces Contests
    before do
      response_body = File.read(File.dirname(__FILE__) + "/mock/codeforces_com_contests_running.html")
      stub_request(:get, 'http://codeforces.com/contests?locale=en').to_return({
        :status => 200,
        :headers => {
          'Content-Type' => 'text/html',
        },
        :body => response_body,
      })
    end

    it 'T002_004_001: Get Contest List' do
      ret = test_get_contest_list_from_codeforces()
      ret[0]["title"].should eq "Codeforces Round #200 (Div. 1)"
      no_dup = get_unique_contest_list(ret)
      no_dup[0]["title"].should eq "Codeforces Round #200"
    end
  end

end
