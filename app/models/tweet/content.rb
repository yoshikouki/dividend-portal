# frozen_string_literal: true

module Tweet
  class Content
    attr_accessor :header_section, :body_section, :footer_section

    def initialize(header: nil, body: nil, footer: nil)
      @header_section = header
      @body_section = body
      @footer_section = footer
    end

    def content(header: nil, body: nil, footer: nil)
      header ||= @header_section
      body ||= @body_section
      footer ||= @footer_section

      @content = ""
      @content += "#{header}\n" if header
      @content += body if body
      @content += "\n#{footer}" if footer
      @content
    end
    alias render content

    def content=(content)
      @body_section = content
    end
  end
end
