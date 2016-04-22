require 'server/contest/common'

module Server
  module Contest
    class Codechef < Base

      def self.filter_contest(title)
        return true if /Challenge\s*[0-9]+/ === title
        return true if /Cook-Off\s*[0-9]+/ === title
        return true if /Lunchtime\s*[0-9]+/ === title
        false
      end

      # Codechefのコンテストリストを取得する
      def self.get_contest_list()
        agent            = Mechanize.new
        agent.user_agent = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)'
        contest_list_url = "https://www.codechef.com/contests"
        page             = agent.get(contest_list_url)
        doc              = Nokogiri::HTML(page.body)
        table            = doc.xpath('//div[@id = "primary-content"]//table')[0]
        contest_list     = []

        table.search('tr')[1..-1].each do |tr|
          contest = {}
          elements = tr.search('td')
          id = elements[0].text.strip
          title = elements[1].search('a')[0].text.strip
          start_time = elements[2].text.strip
          date = DateTime.strptime("#{start_time} IST", "%Y-%m-%d %H:%M:%s %z")
          date = date.new_offset(Rational(9, 24))

          contest["title"] = title
          contest["date"] = date
          contest["tag"] = "CodeChef"
          contest_list.push contest
        end

        contest_list.select! {|contest| filter_contest contest["title"] }

        contest_list
      end
    end
  end
end
