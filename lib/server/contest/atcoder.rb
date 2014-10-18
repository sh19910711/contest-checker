require 'server/contest/common'

module Server

  module Contest

    class AtCoder < Base

      def self.get_contest_list(google_api, google_calendar, user_credentials)
        # Make an API call.
        result = google_api.execute(
          :api_method => google_calendar.events.list,
          :parameters => {'calendarId' => 'atcoder.jp_gqd1dqpjbld3mhfm4q07e4rops@group.calendar.google.com'},
          :authorization => user_credentials,
        )

        items = result.data.items.map do |item|
          date = DateTime.parse(item.start.dateTime.to_s)

          {
            "title" => item.summary,
            "date" => date,
            "tag" => "AtCoder",
          }
        end

        items
      end

    end

  end
  
end
