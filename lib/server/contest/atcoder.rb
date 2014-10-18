require 'server/contest/common'

module Server

  module Contest

    class AtCoder < Base

      def self.get_contest_list(google_api, google_calendar)
        # Make an API call.
        result1 = google_api.execute(
          :api_method => google_calendar.events.list,
          :parameters => {'calendarId' => 'atcoder.jp_gqd1dqpjbld3mhfm4q07e4rops@group.calendar.google.com'},
        )
        result2 = google_api.execute(
          :api_method => google_calendar.events.list,
          :parameters => {'calendarId' => 'atcoder.jp_drp3qk1qgpb84vcdj418fsbo7k@group.calendar.google.com'},
        )

        contest_list = []

        list1 = result1.data.items.map do |item|
          unless item.start["dateTime"].nil?
            date = DateTime.parse(item.start["dateTime"].to_s)
            date = (date.to_time + 3600 * 9).to_datetime
            {
              "title" => item.summary,
              "date" => date,
              "tag" => "AtCoder",
            }
          else
            date = DateTime.strptime("#{item.start["date"].to_s}", "%Y-%m-%d")
            {
              "title" => item.summary,
              "date" => date,
              "tag" => "AtCoder",
              "is_date" => true,
            }
          end
        end.to_a

        list2 = result2.data.items.map do |item|
          unless item.start["dateTime"].nil?
            date = DateTime.parse(item.start["dateTime"].to_s)
            date = (date.to_time + 3600 * 9).to_datetime
            {
              "title" => item.summary,
              "date" => date,
              "tag" => "AtCoder",
            }
          else
            date = DateTime.strptime("#{item.start["date"].to_s}", "%Y-%m-%d")
            {
              "title" => item.summary,
              "date" => date,
              "tag" => "AtCoder",
              "is_date" => true,
            }
          end
        end.to_a

        contest_list.concat list1.to_a
        contest_list.concat list2.to_a
        contest_list
      end

    end

  end
  
end
