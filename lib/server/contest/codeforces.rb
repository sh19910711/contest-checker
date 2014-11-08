require 'active_support/all'
require 'server/contest/common'

module Server
  module Contest
    class Codeforces < Base

      def self.time_parser
        @parser ||= ::ActiveSupport::TimeZone.new("Moscow")
      end

      def self.parse_time(s)
        date = time_parser.parse(s)
        if date.utc_offset != 10800
          date = date.ago(-1.hours) # TODO: fix
        end
        date
      end

      # Codeforcesのコンテストリストを取得する
      def self.get_contest_list()
        agent = Mechanize.new
        agent.user_agent = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)'
        contest_list_url = "http://codeforces.com/contests"
        page = agent.get(contest_list_url, {:locale => 'en'})
        doc = Nokogiri::HTML(page.body)
        element = doc.xpath('//div[@class="contestList"]//div[@class="datatable"]').first
        contest_list = []
        element.search('tr[@data-contestid]').each do |entry|
          elements         = entry.search('td')
          # 時差は5時間
          contest          = {}
          elements[0].search("*").remove()
          contest["title"]  = elements[0].inner_text.strip
          contest["date"]   = parse_time(elements[1].inner_text.strip)
          contest["tag"]    = "Codeforces"
          contest_list.push(contest)
        end
        return contest_list
      end
    end
  end
end
