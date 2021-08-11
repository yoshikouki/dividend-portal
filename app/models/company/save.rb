# frozen_string_literal: true

class Company
  module Save
    class << self
      def create_for_us_with_api(symbols = [])
        # USの取引所のデータだけ保存する
        profiles = Api.profiles(symbols)
        us_profiles = profiles.filter_map do |profile|
          profile.merge(created_at: Time.current, updated_at: Time.current) if Company.new(profile).us_exchange?
        end
        Company.insert_all(us_profiles)
      end
    end
  end
end
