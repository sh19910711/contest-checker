module Server
  module Contest
    class Base
      def self.get_contest_list
        raise
      end
      def self.find_new_contest
        contest_list = get_contest_list
        contest_list = Server::get_unique_contest_list(contest_list)
        contest_list
      end
    end
  end
end
