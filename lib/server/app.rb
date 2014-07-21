require 'server/common'
require 'sinatra/base'
require 'nokogiri'
require 'mechanize'
require 'date'

module Server
  class App < Sinatra::Base
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
end

