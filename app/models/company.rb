# frozen_string_literal: true

class Company < ApplicationRecord
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

  def diff?(target, check_list)
    check_list.each do |c|
      return true unless self[c] == target[c]
    end
    false
  end

  def update_to_least
    profiles = Api.profiles(symbol)
    set_params(profiles[0]).save
  def self.update_all_to_least
    current_all = Company.all.to_a
    latest_all = Api.fetch_us
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
end
