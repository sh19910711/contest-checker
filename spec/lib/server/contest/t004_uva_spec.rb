require 'spec_helper'

module Server
  module Contest
    describe 'T004: UVa' do
      # Fake UVa Contests
      before do
        response_body = read_file_from_mock("/mock/uva_contest.html")
        stub_request(:get, 'http://uva.onlinejudge.org/index.php?option=com_onlinejudge&Itemid=12').to_return({
          :status => 200,
          :headers => {
            'Content-Type' => 'text/html',
          },
          :body => response_body,
        })
      end

      describe '001: Parsing Test' do
        it '001: Get Contest List' do
          ret = Uva::get_contest_list()
          ret.length.should eq 4
          ret[0]["title"].should eq "The 9th Hunan Collegiate Programming Contest Semilive"
          ret[1]["title"].should eq "Latin America Regional"
          ret[2]["title"].should eq "An european regional"
          ret[3]["title"].should eq "An asian regional"
        end
      end

      describe '002: Parsing Test' do
        # Fake UVa Contests
        before do
          response_body = read_file_from_mock("/mock/t004_002.html")
          stub_request(:get, 'http://uva.onlinejudge.org/index.php?option=com_onlinejudge&Itemid=12').to_return({
            :status => 200,
            :headers => {
              'Content-Type' => 'text/html',
            },
            :body => response_body,
          })
        end

        it '001: Get Contest List' do
          ret = Uva::get_contest_list()
          ret.length.should eq 4
          ret[0]["title"].should eq "The 9th Hunan Collegiate Programming Contest Semilive"
          ret[1]["title"].should eq "Latin America Regional"
          ret[2]["title"].should eq "An european regional"
          ret[3]["title"].should eq "An asian regional"
        end
      end
    end
  end
end
