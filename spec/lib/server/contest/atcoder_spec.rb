require 'spec_helper'
require "server/contest/atcoder"

module Server

  module Contest

    describe AtCoder do

      context "date" do

        let(:google_api) do
          obj = {}
          allow(obj).to receive(:execute) do
            obj = {}
            allow(obj).to receive(:data) do
              obj = {}
              allow(obj).to receive(:items) do
                obj1 = {}
                allow(obj1).to receive(:summary) do
                  "dummy"
                end
                allow(obj1).to receive(:start) do
                  {
                    "date" => "2012-05-02",
                  }
                end
                [
                  obj1,
                ]
              end
              obj
            end
            obj
          end
          obj
        end

        let(:google_calendar) do
          obj = {}
          allow(obj).to receive(:events) do
            obj = {}
            allow(obj).to receive(:list) do
            end
            obj
          end
          obj
        end

        subject(:list) do
          AtCoder.get_contest_list(google_api, google_calendar)
        end

        it { expect(list[0]).to have_key("is_date") }

      end # dateTime

      context "dateTime" do

        let(:google_api) do
          obj = {}
          allow(obj).to receive(:execute) do
            obj = {}
            allow(obj).to receive(:data) do
              obj = {}
              allow(obj).to receive(:items) do
                obj1 = {}
                allow(obj1).to receive(:summary) do
                  "dummy"
                end
                allow(obj1).to receive(:start) do
                  {
                    "dateTime" => "2012-05-02T22:30:00+09:00",
                  }
                end
                [
                  obj1,
                ]
              end
              obj
            end
            obj
          end
          obj
        end

        let(:google_calendar) do
          obj = {}
          allow(obj).to receive(:events) do
            obj = {}
            allow(obj).to receive(:list) do
            end
            obj
          end
          obj
        end

        subject(:list) do
          AtCoder.get_contest_list(google_api, google_calendar)
        end

        it { expect(list[0]).not_to have_key("is_date") }

      end # dateTime

    end # AtCoder

  end # Contest

end # Server


