# coding: utf-8

require 'spec_helper'
require "server/contest/codeforces"

module Server
  module Contest
    describe 'T002: Codeforces Parsing Test' do

      def expect_time(s, t)
        expect(Codeforces.parse_time(s).in_time_zone("Asia/Tokyo")).to eq DateTime.parse(t).in_time_zone("Asia/Tokyo")
      end

      describe "Codeforces.parse_time", :current => true do
        context "parse_time" do
          it { expect_time "Nov/10/2014 19:30", "2014-11-11T01:30JST" }
          it { expect_time "Nov/21/2014 19:30", "2014-11-22T01:30JST" }
          it { expect_time "Sep/30/2013 12:45", "2013-09-30T17:45JST" }
        end
      end

      describe '001: Get contest list.1' do
        # Fake Codeforces Contests
        before do
          response_body = read_file_from_mock("/mock/t002_001.html")
          stub_request(:get, 'http://codeforces.com/contests?locale=en').to_return({
            :status => 200,
            :headers => {
              'Content-Type' => 'text/html',
            },
            :body => response_body,
          })
        end

        it '001: Duplicate' do
          ret = Codeforces::get_contest_list()
          ret.length.should == 3
        end

        it '002: Unique' do
          ret1 = Codeforces::get_contest_list()
          ret1.length.should == 3
          ret2 = Server::get_unique_contest_list(ret1)
          ret2.length.should == 2
        end
      end

      describe '002: Get contest list.2' do
        # Fake Codeforces Contests
        before do
          response_body = read_file_from_mock("/mock/t002_002.html")
          stub_request(:get, 'http://codeforces.com/contests?locale=en').to_return({
            :status => 200,
            :headers => {
              'Content-Type' => 'text/html',
            },
            :body => response_body,
          })
        end

        it '001: Duplicate' do
          ret = Codeforces::get_contest_list()
          ret.length.should == 4
        end

        it '002: Unique' do
          ret1 = Codeforces::get_contest_list()
          ret1.length.should == 4
          ret2 = Server::get_unique_contest_list(ret1)
          ret2.length.should == 3
        end
      end

      describe '003: Get contest list.3' do
        # Fake Codeforces Contests
        before do
          response_body = read_file_from_mock("/mock/codeforces_com_contests_20140721.html")
          stub_request(:get, 'http://codeforces.com/contests?locale=en').to_return({
            :status => 200,
            :headers => {
              'Content-Type' => 'text/html',
            },
            :body => response_body,
          })
        end

        it '001: Duplicate' do
          ret = Codeforces::get_contest_list()
          ret.length.should == 2
        end

        it '002: Unique' do
          ret1 = Codeforces::get_contest_list()
          ret1.length.should == 2
          ret2 = Server::get_unique_contest_list(ret1)
          ret2.length.should == 2
        end
      end

      describe '004: Get Contest List(Running)' do
        # Fake Codeforces Contests
        before do
          response_body = read_file_from_mock("/mock/codeforces_com_contests_running.html")
          stub_request(:get, 'http://codeforces.com/contests?locale=en').to_return({
            :status => 200,
            :headers => {
              'Content-Type' => 'text/html',
            },
            :body => response_body,
          })
        end

        it '001: Get Contest List' do
          ret = Codeforces::get_contest_list()
          ret[0]["title"].should eq "Codeforces Round #200 (Div. 1)"
          no_dup = Server::get_unique_contest_list(ret)
          no_dup[0]["title"].should eq "Codeforces Round #200"
        end
      end
    end
  end
end
