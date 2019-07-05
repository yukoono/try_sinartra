# frozen_string_literal: true

require "securerandom"
require "time"
require_relative "app.rb"

class Memo
  include FileNames
  attr_accessor :path, :text

  def self.find(path)
    memo = Memo.new
    File.open(path) do |file|
      memo.path = path
      memo.text = file.read.gsub(/\n/, "<br/>")
    end
    memo
  end

  def self.delete(path)
    FileUtils.rm(path)
  end

  def adupt_text_area
    @text.gsub!(/\r<br\/>/, "&#13;")
    @text.gsub!(/<br\/>/, "&#13;")
  end

  def create(text)
    @text = text
    name = generate_name
    @path = "memo/#{name}"
    save
  end

  def save
    File.open(@path, "w") do |file|
      file.puts @text
    end
  end

  def edit(text)
    @text = text
    save
  end

  private
    def generate_name
      names = FileNames.fetch
      time = Time.now
      name = "#{time}#{SecureRandom.uuid}.txt".gsub(" ", "")
      while names.include?(name) do
        name = "#{time}#{SecureRandom.uuid}.txt".gsub(" ", "")
      end
      name
    end
end
