require 'server/contest/common'

module Server
  module Contest
    class Codeforces < Base
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
          contest["title"] = elements[0].inner_text.strip
          str_date         = elements[1].inner_text.strip
          date             = DateTime.strptime("#{str_date}", "%b/%d/%Y %H:%M")
          date = date.new_offset(Rational(4, 24))
          date -= Rational(4, 24)
          if /PM$/.match(str_date)
            if ( date.hour != 12 )
              date += Rational(12, 24)
            end
          end
          date = date.new_offset(Rational(9, 24))
          contest["date"] = date
          contest["tag"] = "Codeforces"
          contest_list.push(contest)
        end
        return contest_list
      end
    end
  end
end
