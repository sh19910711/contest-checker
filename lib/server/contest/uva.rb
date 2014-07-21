require 'server/contest/common'

module Server
  module Contest
    class Uva < Base
      # UVaのコンテストリストを取得する
      def self.get_contest_list()
        agent            = Mechanize.new
        agent.user_agent = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)'
        contest_list_url = "http://uva.onlinejudge.org/index.php"
        page             = agent.get(contest_list_url, {:option => 'com_onlinejudge', :Itemid => 12})
        doc              = Nokogiri::HTML(page.body)
        table            = doc.xpath('//div[@id="main"]/div[@id="col3"]//table')[0]
        contest_list     = []

        table.search('tr')[1..-1].each do |tr|
          elements = tr.search('td')
          id = elements[0].text.strip
          title = elements[2].search('a').text.strip
          start_time = elements[3].text.strip
          date = DateTime.strptime("#{start_time} UTC", "%Y-%m-%d %H:%M:%s %z")
          date = date.new_offset(Rational(9, 24))

          contest = {}
          contest["title"] = title
          contest["date"] = date
          contest["tag"] = "UVa"
          contest_list.push contest
        end

        contest_list
      end
    end
  end
end
