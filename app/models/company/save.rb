# frozen_string_literal: true

class Company
  module Save
    class << self
      def create_for_us_with_api(symbols = [])
        # 保存されていない企業情報を抽出
        current = Company.where(symbol: symbols)
        missing_symbols = symbols - current.pluck(:symbol)
        return unless missing_symbols.count.positive?

        # USの取引所のデータだけ保存する
        profiles = Api.profiles(missing_symbols)
        profiles.each do |profile|
          company = Company.new(profile)
          company.save if company.us_exchange?
        end
      end
    end
  end
end
