# frozen_string_literal: true

class Company < ApplicationRecord
  validates :symbol,
            presence: true
  validates :name,
            presence: true
  validates :exchange,
            presence: true

  def self.update_all_to_latest
    current_all = Company.all.to_a
    latest_all = Client::Fmp.get_symbols_list
    new_coming = []
    needs_updating = []

    latest_all.each do |raw|
      latest = {
        symbol: raw["symbol"],
        name: raw["name"],
        exchange: raw["exchange"],
      }
      target = current_all.find_index { |cc| cc.symbol == latest[:symbol] }

      # 未知の企業ならインサートする
      if target.nil?
        new_coming << {
          **latest,
          created_at: Time.current,
          updated_at: Time.current,
        }
        next
      end

      current = current_all.slice!(target)
      # 情報を比較して差異があれば更新
      if current.has_diff?(latest, [:name, :exchange])
        needs_updating << {
          **current.attributes.symbolize_keys,
          **latest
        }
      end
    end

    Company.insert_all!(new_coming) if new_coming.count > 0
    Company.upsert_all(needs_updating) if needs_updating.count > 0

    {
      inserted: new_coming,
      updated: needs_updating,
    }
  end

  def has_diff?(target, check_list)
    check_list.each do |c|
      return true unless self[c] == target[c]
    end
    false
  end
end
