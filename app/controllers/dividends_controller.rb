# frozen_string_literal: true

class DividendsController < ApplicationController
  def index
  end

  def recent
    @dividends = Dividend.recent
  end

  def declaration
    @dividends = Dividend.declared_from(Time.at(1.week.ago))
  end
end
