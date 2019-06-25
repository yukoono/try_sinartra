# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"
require "time"

def character?(input)
  if !input.nil?
    !input.delete("\n").delete("\r").empty?
  else
    false
  end
end

get "/" do
  directry_name = Dir.pwd + "/memo"
  file_names = Dir.entries(directry_name)
  file_names.select! { |file_name| file_name[0] != "." }
  file_names.sort!
  @memo = {}
  file_names.each do |file_name|
    file_path = "memo/" + file_name
    File.open(file_path, "r") do |file|
      file.each_line do |line|
        if character?(line)
          @memo[file_path] = line
          break
        end
      end
    end
  end
  erb :index
end

get "/addition" do
  erb :addition
end

get "/addition/alert" do
  @alert = "注意：メモが空欄です。"
  erb :addition
end

get "/detail/*" do |file_path|
  @file_path = file_path
  File.open(file_path, "r") do |file|
    @text = file.read.gsub(/\n/, "<br/>")
  end
  erb :detail
end

get "/mv_addition" do
  redirect "/addition"
end

get "/change/alert/*" do |file_path|
  @file_path = file_path
  File.open(file_path, "r") do |file|
    @text = file.read.gsub(/\n/, "<br/>")
  end
  @alert = "このメモを消去します。よろしいですか？"
  erb :change_alert
end

get "/change/*" do |file_path|
  @file_path = file_path
  @text_lines = []
  File.open(file_path, "r") do |f|
    @text = f.read.gsub(/\r\n/, "&#13;")
  end
  erb :change
end

post "/add_text" do
  input = params[:text]
  if character?(input)
    writeable = 0
    while 1 do
      time = Time.now
      file_path = "memo/text#{time.iso8601(6)}.txt".gsub(" ", "")
      File.open(file_path, "a") do |file|
        if file.flock(File::LOCK_EX | File::LOCK_NB)
          file.puts input
          writeable = 1
          file.flock(File::LOCK_UN)
        end
      end
      if writeable == 1
        break
      end
    end
    redirect "/"
  else
    redirect "/addition/alert"
  end
end

patch "/changed/*" do |file_path|
  input = params[:text]
  if character?(input)
    File.open(file_path, "w") do |file|
      file.write input
    end
    redirect "/"
  else
    alert_uri = "/change/alert/" + file_path
    redirect alert_uri
  end
end

delete "/delete/*" do |file_path|
  FileUtils.rm(file_path)
  redirect "/"
end
