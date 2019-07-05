# frozen_string_literal: true

require_relative "app.rb"

class MemoList
  include Validator
  include FileNames

  def create
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
      names = FileNames.fetch
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
