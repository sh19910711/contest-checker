require 'spec_helper'

module Server
  module Contest
    describe 'T003: Codechef' do
      describe '001: Get Contest List' do
        # Fake Codechef Contests
        before do
          response_body = read_file_from_mock("/mock/codechef_contest.html")
          WebMock.stub_request(:get, 'http://www.codechef.com/contests').to_return({
            :status => 200,
            :headers => {
              'Content-Type' => 'text/html',
            },
            :body => response_body,
          })
        end

        it '001: Get Contest List' do
          ret = Codechef::get_contest_list()
          ret.length.should eq 1
          ret[0]["title"].should eq "September Cook-Off 2013"
        end
      end
    end
  end
end
