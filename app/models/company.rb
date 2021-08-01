# frozen_string_literal: true

class Company < ApplicationRecord
  validates :symbol,
            presence: true
  validates :name,
            presence: true
  validates :exchange,
            presence: true

  def diff?(target, check_list)
    check_list.each do |c|
      return true unless self[c] == target[c]
    end
    false
  end

  def self.update_to_least
    current_all = Company.all.to_a
    latest_all = Client::Fmp.get_symbols_list
    new_coming = []
    needs_updating = []

    latest_all.each do |latest|
      # API のレスポンスに不要な情報が含まれているので削除
      latest.delete(:price)
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
