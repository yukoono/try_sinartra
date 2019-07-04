# frozen_string_literal: true

require "securerandom"
require "time"

module Validator
  def self.character?(text)
    if !text.nil?
      !text.delete("\n").delete("\r").empty?
    else
      false
    end
  end
end

module FileNames
  def self.read
    directry_name = Dir.pwd + "/memo"
    file_names = Dir.entries(directry_name)
    file_names.select! { |file_name| file_name[0] != "." }
  end
end

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
      names = FileNames.read
      time = Time.now
      name = "#{time}#{SecureRandom.uuid}.txt".gsub(" ", "")
      while names.include?(name) do
        name = "#{time}#{SecureRandom.uuid}.txt".gsub(" ", "")
      end
      name
    end
end

class Memo::List
  include Validator, FileNames

  def make
    names = group
    list = {}
    names.each do |name|
      path, line = read_line(name)
      list[path] = line
    end
    list
  end

  private
    def group
      names = FileNames.read
      names.sort!.reverse!
    end

    def read_line(name)
      path = "memo/" + name
      File.open(path, "r") do |file|
        file.each_line do |line|
          if Validator.character?(line)
            return path, line
          end
        end
      end
    end
end
