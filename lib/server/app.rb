require 'server/common'
require 'sinatra/base'
require 'nokogiri'
require 'mechanize'
require 'date'
require 'time'
require 'google/api_client'
require 'hatenagroup'

module Server
  class App < Sinatra::Base

    configure :production, :development do

      def google_calendar; settings.google_calendar; end
      def google_api; settings.google_api; end

      configure do
        client = Google::APIClient.new(
          :application_name => 'Contest Checker',
        )
        client_key = OpenSSL::PKey::RSA.new(ENV['CHECK_CF_CONTEST_GOOGLE_KEY'])
        client.authorization = Signet::OAuth2::Client.new(
          :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
          :audience             => 'https://accounts.google.com/o/oauth2/token',
          :scope                => [
            'https://www.googleapis.com/auth/userinfo.email',
            'https://www.googleapis.com/auth/calendar.readonly',
          ],
          :issuer               => ENV["CHECK_CF_CONTEST_GOOGLE_CLIENT_ID"],
          :signing_key          => client_key,
        )
        client.authorization.fetch_access_token!
        set :google_api, client

        calendar = google_api.discovered_api('calendar', 'v3')
        set :google_calendar, calendar
      end

      post "/#{CHECK_CF_CONTEST_SECRET_URL}/fetch-google-calendar" do
        halt 403 if CHECK_CF_CONTEST_SECRET_TOKEN != params[:token]
        Server::find_new_contest_from_calendar(google_api, google_calendar)
        "ok"
      end
    end

    configure :development do

      get "/#{CHECK_CF_CONTEST_SECRET_URL}/fetch-google-calendar" do
        [
          '<form action="" method="post">',
          '<input type="text" name="token" value="">',
          '</form>',
        ].join("")
      end

    end

    get '/version' do
      '20141108'
    end

    post "/#{CHECK_CF_CONTEST_SECRET_URL}/fetch" do
      halt 403 if CHECK_CF_CONTEST_SECRET_TOKEN != params[:token]
      Server::find_new_contest()
      'OK'
    end

    configure :development do
      puts "### DEVELOPMENT_MODE ###"
      puts "HATENA GROUP ID = #{CHECK_CF_CONTEST_HATENA_GROUP_ID}"
      get "/check" do
        halt 403 unless ENV['DEVELOPMENT_MODE'] === 'TRUE'
        Server::find_new_contest()
        'OK'
      end
    end
  end

  module_function

  # 指定した日付にテキストを追加する
  def test_set_data_to_hatena_group_calendar(calendar, contest)
    date = contest["date"]
    return if date < DateTime.now
    date = date.in_time_zone("Tokyo")
    p "add: #{contest}"
    keyword_date = get_keyword_date(date)
    str_date = get_str_date(date)
    title    = contest["title"]
    tag      = contest["tag"]
    if contest["is_date"]
      data     = "* #{title}"
    else
      data     = "* #{str_date} #{title}"
    end

    # 追加済みのデータがあるときは何もしない
    day = calendar.day(keyword_date)
    unless day.body.include?(title)
      day.body = "#{day.body.strip}\n#{get_contest_line(contest)}\n"
    end
  end

  def get_keyword_date(date)
    date.strftime("%Y-%m-%d")
  end

  def get_str_date(date)
    date.strftime("%H:%M")
  end

  def find_new_contest
    contests = [
      Contest::Codeforces,
      Contest::Codechef,
      Contest::Uva,
      Contest::Toj,
      Contest::HackerRank,
    ]

    calendar = ::HatenaGroup::Calendar.new(
      CHECK_CF_CONTEST_HATENA_GROUP_ID,
      CHECK_CF_CONTEST_HATENA_USER_ID,
      CHECK_CF_CONTEST_HATENA_USER_PASSWORD,
    )

    contests.each do |contest|
      contest.find_new_contest.each do |item|
        test_set_data_to_hatena_group_calendar(calendar, item)
      end
    end
  end

  def find_new_contest_from_calendar(google_api, google_calendar)
    calendar = ::HatenaGroup::Calendar.new(
      CHECK_CF_CONTEST_HATENA_GROUP_ID,
      CHECK_CF_CONTEST_HATENA_USER_ID,
      CHECK_CF_CONTEST_HATENA_USER_PASSWORD,
    )

    contest_list = Contest::AtCoder.find_new_contest_from_calendar(google_api, google_calendar)
    contest_list.each do |item|
      test_set_data_to_hatena_group_calendar(calendar, item)
    end
  end

end

