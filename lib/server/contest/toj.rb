require 'server/contest/common'

module Server
  module Contest
    class Toj < Base
      # Codechefのコンテストリストを取得する
      def self.get_contest_list()
        agent            = Mechanize.new
        agent.user_agent = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)'
        contest_list_url = "http://acm.timus.ru/schedule.aspx"
        page             = agent.get(contest_list_url)
        doc              = Nokogiri::HTML(page.body)
        elements = doc.xpath('//ul//a').select do |element|
          /^contest\.aspx/.match element.get_attribute('href')
        end
        contest_list     = []

        elements.each do |element|
          # url = contest.aspx?id=170
          url = element.get_attribute('href')
          contest_id = /\?id=([0-9]+)/.match(url)[1].to_i
          contest = get_contest_info(contest_id)
          contest_list.push contest
        end

        contest_list
      end

      def self.get_contest_info id
        agent            = Mechanize.new
        agent.user_agent = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)'
        contest_page_url = "http://acm.timus.ru/contest.aspx?id=#{id}"
        page             = agent.get(contest_page_url)
        doc              = Nokogiri::HTML(page.body)
        title            = doc.xpath('//h2[@class="title"]').text.strip
        start_text       = doc.text.match(/Contest starts at (.*?)\./)[1].gsub('Yekaterinburg time', '')
        date             = DateTime.parse(start_text)
        date             = date.new_offset(Rational(9, 24))

        contest          = {}
        contest["title"] = title
        contest["tag"]   = "TOJ"
        contest["date"]  = date
        contest
      end
    end
  end
end
