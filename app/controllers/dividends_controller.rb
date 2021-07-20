# frozen_string_literal: true

class DividendsController < ApplicationController
  def index
  end

  def recent
    @dividends = Dividend.convert_calendar_for_visual(Dividend::Api.recent)
  end

  def declaration
    @dividends = Dividend.declared_from(Time.at(1.week.ago))
  end
end
