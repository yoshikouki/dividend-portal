# frozen_string_literal: true

class Company
  module Save
    class << self
      def create_for_us_with_api(symbols = [])
        # USの取引所のデータだけ保存する
        profiles = Api.profiles(symbols)
        profiles.each do |profile|
          company = Company.new(profile)
          company.save if company.us_exchange?
        end
      end
    end
  end
end
