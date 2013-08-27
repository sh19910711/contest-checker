require 'mechanize'
require 'date'
require 'sinatra/base'

CHECK_CF_CONTEST_HATENA_USER_ID=ENV['CHECK_CF_CONTEST_HATENA_USER_ID']
CHECK_CF_CONTEST_HATENA_USER_PASSWORD=ENV['CHECK_CF_CONTEST_HATENA_USER_PASSWORD']
CHECK_CF_CONTEST_HATENA_GROUP_ID=ENV['CHECK_CF_CONTEST_HATENA_GROUP_ID']
CHECK_CF_CONTEST_SECRET_URL=ENV['CHECK_CF_CONTEST_SECRET_URL']
CHECK_CF_CONTEST_SECRET_TOKEN=ENV['CHECK_CF_CONTEST_SECRET_TOKEN']

# 指定したはてなグループのカレンダーにテキストを追加する実験
# 指定した日付にテキストを追加する
def test_set_data_to_hatena_group_calendar(group_id, date, data)
  agent = Mechanize.new
  agent.user_agent = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)'
  agent.verify_mode = OpenSSL::SSL::VERIFY_NONE

  login_url = 'https://www.hatena.ne.jp/login'
  target_url = "http://#{group_id}.g.hatena.ne.jp/keyword/#{date.strftime("%Y-%m-%d")}?mode=edit"
  page = agent.get(login_url)
  next_page = page.form_with do |form|
    form["name"] = CHECK_CF_CONTEST_HATENA_USER_ID
    form["password"] = CHECK_CF_CONTEST_HATENA_USER_PASSWORD
  end.submit

  # 追加済みのデータがあるときは何もしない
  agent.get(target_url).form_with(:name => 'edit') do |form|
    break if form["body"].include?(data)
    form["body"] += data
    form.submit
  end
end

# test_set_data_to_hatena_group_calendar("nsz5k0ad", Date.today, "* 00:16 test 1\n* 00:45 test 2")

# Codeforcesのコンテストリストを取得する
def test_get_contest_list_from_codeforces()
  agent = Mechanize.new
  agent.user_agent = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)'

  contest_list_url = "http://codeforces.com/contests?locale=en"
  page = agent.get(contest_list_url)
  doc = Nokogiri::HTML(page.body)
  element = doc.xpath('//div[@class="contestList"]//div[@class="datatable"]').first
  contest_list = []
  element.search('tr[@data-contestid]').each do |entry|
    elements = entry.search('td')

    # 時差は5時間
    contest = {}
    contest["title"] = elements[0].inner_text.strip
    str_date = elements[1].inner_text.strip
    date =  DateTime.strptime(str_date, "%m/%d/%Y %H:%M")
    date += Rational(12, 24) if /PM$/.match(str_date)
    date += Rational(5, 24)
    contest["date"] = date

    contest_list.push(contest)
  end

  return contest_list
end

# 重複するコンテスト（Div.1 Div.2など）を一つにまとめる処理
def get_unique_contest_list(contest_list)
  pass_list = Hash.new
  res = []
  len = contest_list.length
  (0..(len-1)).each do |i|
    ok = true
    date_i = contest_list[i]["date"]
    title_i = contest_list[i]["title"]

    next if pass_list.key?(/(.*)\(Div.\s?[12]\)/.match(title_i)[1].strip)

    ((i+1)..(len-1)).each do |j|
      date_j = contest_list[j]["date"]
      title_j = contest_list[j]["title"]
      if ( date_i == date_j )
        regexp = /\(Div.\s?[12]\)/
        if ( regexp.match(title_i) && regexp.match(title_j) )
          contest_title = /(.*)\(Div.\s?[12]\)/.match(title_i)[1].strip
          res.push({
            "title" => contest_title,
            "date" => contest_list[i]["date"]
          })
          pass_list[contest_title] = true
          ok = false
        end
      end
    end

    res.push contest_list[i] if ok
  end

  res
end

def find_new_contest()
  contest_list = test_get_contest_list_from_codeforces
  contest_list = get_unique_contest_list(contest_list)

  contest_list.each do |contest|
    date = contest["date"]
    str_date = date.strftime("%H:%M")
    title = contest["title"]
    test_set_data_to_hatena_group_calendar(CHECK_CF_CONTEST_HATENA_GROUP_ID, date, "* #{str_date} #{title}\n")
  end
end

class App < Sinatra::Base
  post '/' + CHECK_CF_CONTEST_SECRET_URL do
    halt 403 if CHECK_CF_CONTEST_SECRET_TOKEN != params[:token]
    find_new_contest()
    'hoge: OK'
  end
end

