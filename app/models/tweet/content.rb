# frozen_string_literal: true

module Tweet
  class Content
    attr_accessor :header_section, :main_section, :footer_section

    MAX_WEIGHTED_LENGTH = 280

    def initialize(header: nil, main: nil, footer: nil)
      @header_section = header
      @main_section = main
      @footer_section = footer
    end

    def content(header: nil, main: nil, footer: nil)
      header ||= @header_section
      main ||= @main_section
      footer ||= @footer_section

      @content = ""
      @content += "#{header}\n" if header
      @content += main if main
      @content += "\n#{footer}" if footer
      @content
    end
    alias render content

    def content=(content)
      @main_section = content
    end

    # Twitter上の文字数を算出する
    def weighted_length(header: nil, main: nil, footer: nil)
      tmp_content = content(header: header, main: main, footer: footer)
      Content.weighted_length(tmp_content)
    end

    def self.weighted_length(text)
      validation = Twitter::TwitterText::Validation.parse_tweet(text)
      validation[:weighted_length]
    end
  end
end
