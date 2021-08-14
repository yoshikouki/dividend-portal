# frozen_string_literal: true

class Company < ApplicationRecord
  has_many :dividends, dependent: :destroy
  has_many :company_tags
  has_many :tags, through: :company_tags

  scope :us_exchanges, -> { where(exchange_short_name: %w[NYSE NASDAQ AMEX]) }
  scope :dividend_aristocrats, -> { includes(:tags).joins(:tags).merge(Tag.dividend_aristocrats) }

  validates :symbol,
            presence: true
  validates :name,
            presence: true
  validates :exchange,
            presence: true

  DIVIDEND_ARISTOCRATS = %w[
    MMM AOS ABT ABBV AFL APD ALB AMCR ADM T ATO ADP BDX BF-B CAH CAT CVX CB CINF CTAS CLX KO CL ED DOV ECL EMR ESS EXPD XOM FRT BEN GD
    GPC HRL ITW IBM JNJ KMB LEG LIN LOW MKC MCD MDT NEE NUE PNR PBCT PEP PPG PG O ROP SPGI SHW SWK SYY TROW TGT VFC GWW WBA WMT WST
  ].freeze

  # exchange の表記揺れがあるため、正規表現を定義する
  REGEXP_NASDAQ = /NASDAQ/i
  REGEXP_NYSE = /(New York|NYSE)/i

  # FMP-profile のAPIに則っていない古い仕様なので非推奨
  def diff?(target, check_list)
    check_list.each do |c|
      return true unless self[c] == target[c]
    end
    false
  end

  def update_with_api
    profiles = Api.profiles(symbol)
    assign_attributes(profiles[0]).save
  end

  class << self
    def update_all_with_api
      current_all = Company.all.to_a
      latest_all = Api.fetch_all
      new_coming = []
      needs_updating = []

      latest_all.each do |latest|
        target_index = current_all.find_index { |cc| cc.symbol == latest[:symbol] }

        # 未知の企業ならインサートする
        if target_index.nil?
          new_coming << {
            **latest,
            created_at: Time.current,
            updated_at: Time.current,
          }
          next
        end

        # 情報を比較して差異があれば更新
        current = current_all.slice!(target_index)
        next unless current.diff?(latest, %i[name exchange])

        needs_updating << {
          **current.attributes.symbolize_keys,
          **latest,
        }
      end

      Company.insert_all!(new_coming) if new_coming.count.positive?
      Company.upsert_all(needs_updating) if needs_updating.count.positive?
    end

    def update_dividend_aristocrats
      dividend_aristocrats = DIVIDEND_ARISTOCRATS
      profiles = Api.profiles(dividend_aristocrats)
      profiles.each do |profile|
        company = find_or_initialize_by(symbol: profile[:symbol])
        company.assign_attributes(profile).save
      end
    end

    def in_us_where_or_create_by_symbol(symbols)
      # 保存されていない企業情報を抽出
      symbols = symbols.map { |symbol| Client::Fmp.convert_symbol_to_profile_query(symbol) }
      current = us_exchanges.where(symbol: symbols)
      missing_symbols = symbols - current.pluck(:symbol)

      # 不足している企業情報を作る
      if missing_symbols.present?
        Save.create_for_us_with_api(missing_symbols)
        us_exchanges.where(symbol: symbols)
      else
        current
      end
    end
  end

  def assign_attributes(params)
    attribute_names.each do |attr|
      next unless params[attr.to_sym]

      self[attr] = params[attr.to_sym]
    end
    self
  end

  def us_exchange?
    nyse? || nasdaq?
  end

  def nyse?
    REGEXP_NYSE.match?(exchange)
  end

  def nasdaq?
    REGEXP_NASDAQ.match?(exchange)
  end
end
