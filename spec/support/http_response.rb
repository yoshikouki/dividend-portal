# frozen_string_literal: true

class HTTPResponseMock
  include ActiveModel

  attr_reader :body

  def initialize(body: nil, header: nil)
    @body = body
    @header = header || {}
  end

  def [](key)
    @header[key.downcase.to_s] || nil
  end

  def []=(key, val)
    unless val
      @header.delete key.downcase.to_s
    end
    set_field(key, val)
  end
end
