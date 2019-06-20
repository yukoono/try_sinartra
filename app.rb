require 'sinatra'
require 'sinatra/reloader'
require 'time'

get '/' do
  directry_name = ARGV[0] || Dir.pwd + "/memo"
  file_names = Dir.entries(directry_name)
  file_names.select! { |file_name| file_name[0] != "." }
  file_names.sort!
  @memo = {}
  file_names.each do |file_name|
    file_path = "memo/" + file_name
    File.open(file_path,'r') do |f|
      @memo[file_path] = f.gets
    end
  end
  erb :index
end

get '/new' do
  erb :new
end

get '/new/alert' do
  @alert = "注意：メモが空欄です。"
  erb :new
end

get '/detail/*' do |file_name|
  @file_name = file_name
  @text_lines = []
  File.open(file_name, 'r') do |f|
    f.each_line do |line|
      @text_lines << line.gsub(/\n/,'<br/>')
    end
  end
  erb :memo_detail
end

get '/mv_new' do
  redirect '/new'
end

post '/add_text' do
  unless params[:text].delete("\n").delete("\r").empty?
    writeable = 0
    while 1 do
      time = Time.now
      File.open("memo/text#{time}.txt",'a') do |f|
        if f.flock(File::LOCK_EX|File::LOCK_NB)
          f.puts params[:text]
          writeable = 1
          f.flock(File::LOCK_UN)
        end
      end
      if writeable == 1
        break
      end
    end
    redirect '/'
  else
    redirect '/new/alert'
  end
end

get '/change/alert/*' do |file_name|
  @file_name = file_name
  @text_lines = []
  File.open(file_name, 'r') do |f|
    f.each_line do |line|
      @text_lines << line.gsub(/\n/,'<br/>')
    end
  end
  @alert = "このメモを消去します。よろしいですか？"
  erb :change_alert
end

patch '/change/*' do |file_name|
  @file_name = file_name
  @text_lines = []
  File.open(file_name, 'r') do |f|
    f.each_line do |line|
      @text_lines << line
    end
  end
  erb :change
end

patch '/changed/*' do |file_name|
  unless params[:text].delete("\n").delete("\r").empty?
    File.open(file_name, 'w') do |f|
      f.write params[:text]
    end
    redirect '/'
  else
    alert_address = "/change/alert/"+file_name.gsub(/ /,'%20')
    redirect alert_address
  end
end

delete '/delete/*' do |file_name|
  FileUtils.rm(file_name)
  redirect '/'
end