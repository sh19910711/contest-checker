require "spec_helper"
require "server/contest/hackerrank"

module Server::Contest

  describe HackerRank, :hackerrank => true do

    before do
      res = read_file_from_mock("/mock/hackerrank.rss")
      WebMock.stub_request(:get, /https?:\/\/www\.hackerrank\.com\/calendar\/feed\.rss/).to_return({
        :status => 200,
        :headers => {
          'Content-Type' => 'application/rss+xml',
        },
        :body => res,
      })
    end

    let(:contest_list) do
      HackerRank.get_contest_list.map {|contest| contest["title"] }
    end

    it { expect(contest_list.length).to eq 6 }
    it { expect(contest_list).to include "Weekly Challenges - Week 13" }
    it { expect(contest_list).to include "101 Hack November'14" }

  end

end
