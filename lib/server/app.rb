require 'server/common'
require 'sinatra/base'
require 'sinatra/reloader'
require 'nokogiri'
require 'mechanize'
require 'date'
require 'google/api_client'

module Server
  class App < Sinatra::Base
    configure :devleopment do
      register Sinatra::Reloader
    end

    configure do
      enable :sessions

      def google_calendar; settings.google_calendar; end
      def google_api; settings.google_api; end

      def user_credentials
        # Build a per-request oauth credential based on token stored in session
        # which allows us to use a shared API client.
        @authorization ||= (
          auth = google_api.authorization.dup
          auth.redirect_uri = to('/google/login/callback')
          auth.update_token!(session[:google_api] || {})
          auth
        )
      end

      configure do
        client = Google::APIClient.new(
          :application_name => 'Contest Checker',
        )
        client.authorization.client_id = ENV["CHECK_CF_CONTEST_GOOGLE_CLIENT_ID"]
        client.authorization.client_secret = ENV["CHECK_CF_CONTEST_GOOGLE_CLIENT_SECRET"]
        client.authorization.scope = [
          'https://www.googleapis.com/auth/userinfo.email',
          'https://www.googleapis.com/auth/calendar.readonly',
        ]
        set :google_api, client

        calendar = google_api.discovered_api('calendar', 'v3')
        set :google_calendar, calendar
      end

      get '/google/login/callback' do
        halt 403 if CHECK_CF_CONTEST_SECRET_TOKEN != session[:check_token]

        user_credentials.code = params[:code] if params[:code]
        user_credentials.fetch_access_token!
        session[:google_api] = {}
        session[:google_api][:access_token] = user_credentials.access_token
        session[:google_api][:refresh_token] = user_credentials.refresh_token
        session[:google_api][:expires_in] = user_credentials.expires_in
        session[:google_api][:issued_at] = user_credentials.issued_at

        result = google_api.execute(
          :api_method => google_api.discovered_api('oauth2', 'v2').userinfo.get,
          :authorization => user_credentials,
        )

        session[:google_api][:user_id] = result.data.id

        if session[:google_api][:user_id] != ENV["CHECK_CF_CONTEST_GOOGLE_CLIENT_USER"]
          user_credentials = nil
          raise "error"
        end

        redirect to('/hello')
      end

      post '/google/login' do
        halt 403 if CHECK_CF_CONTEST_SECRET_TOKEN != params[:token]
        session[:check_token] = params[:token]
        redirect user_credentials.authorization_uri.to_s, 303
      end

      post '/fetch/google/calendar' do
        halt 403 if CHECK_CF_CONTEST_SECRET_TOKEN != params[:token]
        halt 500 unless user_credentials.access_token
        Server::find_new_contest_from_calendar(google_api, google_calendar, user_credentials)
        "ok"
      end
    end

    configure :development do

      get '/fetch/google/calendar' do
        [
          '<form action="" method="post">',
          '<input type="text" name="token" value="">',
          '</form>',
        ].join("")
      end

      get '/google/whoami' do
        session[:google_api][:user_id]
      end

      get '/hello' do
        unless user_credentials.access_token
          return "<form method='post' action='/google/login'><input type='text' name='token'></form>"
        end
      end
    end

    get '/version' do
      '20140208'
    end

    post "/#{CHECK_CF_CONTEST_SECRET_URL}" do
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

  # 指定したはてなグループのカレンダーにテキストを追加する実験
  # 指定した日付にテキストを追加する
  def test_set_data_to_hatena_group_calendar(group_id, contest)
    date     = contest["date"]
    return if date < DateTime.now
    str_date = date.strftime("%H:%M")
    title    = contest["title"]
    tag      = contest["tag"]
    data     = "* #{str_date} #{title}"
    agent             = Mechanize.new
    agent.user_agent  = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)'
    agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
    login_url = 'https://www.hatena.ne.jp/login'
    page      = agent.get(login_url)
    next_page = page.form_with do |form|
      form["name"]     = CHECK_CF_CONTEST_HATENA_USER_ID
      form["password"] = CHECK_CF_CONTEST_HATENA_USER_PASSWORD
    end.submit
    # 追加済みのデータがあるときは何もしない
    target_url = "https://#{group_id}.g.hatena.ne.jp/keyword/#{date.strftime("%Y-%m-%d")}?mode=edit"
    agent.get(target_url).form_with(:name => 'edit') do |form|
      next unless form
      break if form["body"].include?(title)
      form["body"] += "\n" + get_contest_line(contest) + "\n"
      form.submit
    end
  end


  def find_new_contest_from_contest(contest)
    contest_list = contest.find_new_contest
    contest_list.each do |item|
      test_set_data_to_hatena_group_calendar(CHECK_CF_CONTEST_HATENA_GROUP_ID, item)
    end
  end

  def find_new_contest
    find_new_contest_from_contest Contest::Codeforces
    find_new_contest_from_contest Contest::Codechef
    find_new_contest_from_contest Contest::Uva
    find_new_contest_from_contest Contest::Toj
  end

  def find_new_contest_from_calendar(google_api, google_calendar, user_credentials)
    contest_list = Contest::AtCoder.find_new_contest_from_calendar(google_api, google_calendar, user_credentials)
    contest_list.each do |item|
      test_set_data_to_hatena_group_calendar(CHECK_CF_CONTEST_HATENA_GROUP_ID, item)
    end
  end

end

