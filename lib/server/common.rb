require 'server/app'
require 'server/contest/codeforces'
require 'server/contest/uva'
require 'server/contest/codechef'
require 'server/contest/toj'
require 'server/contest/atcoder'

module Server
  CHECK_CF_CONTEST_HATENA_USER_ID       = ENV['CHECK_CF_CONTEST_HATENA_USER_ID']
  CHECK_CF_CONTEST_HATENA_USER_PASSWORD = ENV['CHECK_CF_CONTEST_HATENA_USER_PASSWORD']
  CHECK_CF_CONTEST_HATENA_GROUP_ID      = ENV['CHECK_CF_CONTEST_HATENA_GROUP_ID']
  CHECK_CF_CONTEST_SECRET_URL           = ENV['CHECK_CF_CONTEST_SECRET_URL']
  CHECK_CF_CONTEST_SECRET_TOKEN         = ENV['CHECK_CF_CONTEST_SECRET_TOKEN']

  module_function

  # 重複するコンテスト（Div.1 Div.2など）を一つにまとめる処理
  def get_unique_contest_list(contest_list)
    pass_list = Hash.new
    res       = []
    len       = contest_list.length
    (0..(len-1)).each do |i|
      ok      = true
      date_i  = contest_list[i]["date"]
      title_i = contest_list[i]["title"]
      if /(.*)\(Div.\s?[12]\)/.match(title_i) && pass_list.key?(/(.*)\(Div.\s?[12]\)/.match(title_i)[1].strip)
        next
      end
      ((i+1)..(len-1)).each do |j|
        date_j  = contest_list[j]["date"]
        title_j = contest_list[j]["title"]
        if ( date_i == date_j )
          regexp = /\(Div.\s?[12]\)/
          if ( regexp.match(title_i) && regexp.match(title_j) )
            contest_title = /(.*)\(Div.\s?[12]\)/.match(title_i)[1].strip
            res.push({
              "title" => contest_title,
              "date"  => contest_list[i]["date"],
              "tag"   => contest_list[i]["tag"]
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

  # はてなグループのカレンダー用のテキストを取得する
  def get_contest_line(contest)
    date     = contest["date"]
    title    = contest["title"]
    tag      = contest["tag"]
    if contest["is_date"]
      str_date = ""
    else
      str_date = "#{date.in_time_zone("Tokyo").strftime("%H:%M")} "
    end
    title.include?(tag) ?  "* #{str_date}#{title}" : "* #{str_date}[#{tag}] #{title}"
  end
end
