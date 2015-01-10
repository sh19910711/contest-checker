module Server

  module Contest

    require "open-uri"
    require "rexml/document"
    
    class HackerRank < Base

      def self.is_hackerrank?(url)
        /^https?:\/\/www.hackerrank.com\// === url
      end

      def self.get_contest_list
        xml = REXML::Document.new(open "https://www.hackerrank.com/calendar/feed.rss")
        xml.elements.each("rss/channel/item") do
        end.select do |item|
          is_hackerrank?(item.elements["url"].text)
        end.map do |item|
          {
            "title" => item.elements["title"].text,
            "date" => DateTime.parse(item.elements["startTime"].text),
            "tag" => "HackerRank",
          }
        end
      end

    end

  end

end
