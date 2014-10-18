require 'spec_helper'
require 'server/app'

module Server
  describe 'T005: Server::get_contest_line' do
    describe '001: No tag cases' do
      it "is_date" do
        date = Time.new
        date_text = date.strftime('%H:%M')
        ret = Server::get_contest_line(
          "title" => "Title",
          "tag" => "Tag",
          "date" => date,
          "is_date" => true,
        )
        ret.should == "* [Tag] Title"
      end
      it '001' do
        date = Time.new
        date_text = date.strftime('%H:%M')
        ret = Server::get_contest_line(
          {
            "title" => "Hello",
            "tag" => "Hello",
            "date" => date,
          },
        )
        ret.should === "* #{date_text} Hello"
      end
      it '002' do
        date = Time.new
        date_text = date.strftime('%H:%M')
        ret = Server::get_contest_line(
          {
            "title" => "Fullo",
            "tag" => "Hello",
            "date" => date,
          },
        )
        ret.should === "* #{date_text} [Hello] Fullo"
      end
      it '003: check upper/lower cases' do
        date = Time.new
        date_text = date.strftime('%H:%M')
        ret = Server::get_contest_line(
          {
            "title" => "Hello",
            "tag" => "hello",
            "date" => date,
          },
        )
        ret.should === "* #{date_text} [hello] Hello"
      end
      it '004' do
        date = Time.new
        date_text = date.strftime('%H:%M')
        ret = Server::get_contest_line(
          {
            "title" => "Hello World",
            "tag" => "Hello",
            "date" => date,
          },
        )
        ret.should === "* #{date_text} Hello World"
      end
      it '005' do
        date = Time.new
        date_text = date.strftime('%H:%M')
        ret = Server::get_contest_line(
          {
            "title" => "Super Hello World",
            "tag" => "Hello",
            "date" => date,
          },
        )
        ret.should === "* #{date_text} Super Hello World"
      end
    end
  end
end
