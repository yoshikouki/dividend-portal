# frozen_string_literal: true

module Tweet
  class Content
    attr_accessor :header_section, :body_section, :footer_section

    def initialize(header: "", body: "", footer: "")
      @header_section = header
      @body_section = body
      @footer_section = footer
    end

    def content(header: nil, body: nil, footer: nil)
      @content = ""
      @content += header || @header_section
      @content += body || @body_section
      @content += footer || @footer_section
      @content
    end
    alias render content

    def content=(content)
      @body_section = content
    end
  end
end
