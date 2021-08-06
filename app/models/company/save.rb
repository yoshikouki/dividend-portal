# frozen_string_literal: true

class Company
  module Save
    class << self
      def create_by_us(symbols = [])
        # 保存されていない企業情報を抽出
        current = Company.where(symbol: symbols)
        missing_symbols = symbols - current.pluck(:symbol)
        profiles = Api.profiles(missing_symbols)

        # USの取引所のデータだけ保存する
        profiles.each do |profile|
          company = Company.new(profile)
          company.save if company.us_exchange?
        end
      end
    end
  end
end
