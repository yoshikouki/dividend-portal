# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tweet::Content, type: :model do
  describe "#content" do
    context "引数が空の場合" do
      it "セクション情報がない場合は空文字列を返す" do
        expect(Tweet::Content.new.content).to eq ""
      end

      it "インスタンスで持っているセクション情報を元にコンテンツを返す" do
        content = Tweet::Content.new(
          header: "header_section",
          main: "main_section",
          footer: "footer_section",
        )
        actual = content.content
        expected = "header_section\nmain_section\nfooter_section"
        expect(actual).to eq expected
      end

      it "セクション情報は定義しなくても良い" do
        content = Tweet::Content.new(
          main: "main_section",
          footer: "footer_section",
        )
        actual = content.content
        expected = "main_section\nfooter_section"
        expect(actual).to eq expected
      end

      it "エイリアス #render を持つ" do
        content = Tweet::Content.new(
          header: "header_section",
          main: "main_section",
          footer: "footer_section",
        )
        actual = content.render
        expected = "header_section\nmain_section\nfooter_section"
        expect(actual).to eq expected
      end
    end

    context "引数が渡されている場合" do
      it "引数に応じてコンテンツ内容を非破壊的に上書きした文字列返す" do
        content = Tweet::Content.new(
          header: "header_section",
          main: "main_section",
          footer: "footer_section",
        )
        actual = content.content(
          header: "header",
          main: "main",
        )
        expected = "header\nmain\nfooter_section"
        expect(actual).to eq expected

        # 非破壊的なのでインスタンス変数は変更されていない
        actual = content.content
        expected = "header_section\nmain_section\nfooter_section"
        expect(actual).to eq expected
      end
    end
  end

  describe "#content=" do
    it "content への直接代入は main_section に代入される" do
      content = Tweet::Content.new
      content.content = "test string"
      expect(content.content).to eq content.main_section
    end
  end
end
