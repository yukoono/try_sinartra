# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"
require_relative "validator"
require_relative "memo"
require_relative "memo_list"

ROOT_DIR = File.expand_path(File.dirname(__FILE__))
also_reload File.join(ROOT_DIR, "memo.rb")
also_reload File.join(ROOT_DIR, "memo_list.rb")

get "/" do
  @list = Memo::List.new.create
  erb :index
end

get "/addition" do
  erb :addition
end

get "/addition/alert" do
  @alert = "注意：メモが空欄です。"
  erb :addition
end

get "/detail/*" do |path|
  @memo = Memo.find(path)
  erb :detail
end

get "/mv_addition" do
  redirect "/addition"
end

get "/change/alert/*" do |path|
  @memo = Memo.find(path)
  @alert = "このメモを消去します。よろしいですか？"
  erb :change_alert
end

get "/change/*" do |path|
  @memo = Memo.find(path)
  @memo.adupt_text_area
  erb :change
end

post "/add_memo" do
  text = params[:text]
  if Validator.character?(text)
    @memo = Memo.new.create(text)
    redirect "/"
  else
    redirect "/addition/alert"
  end
end

patch "/changed/*" do |path|
  text = params[:text]
  @memo = Memo.find(path)
  if Validator.character?(text)
    @memo.edit(text)
    redirect "/"
  else
    alert_uri = "/change/alert/" + path
    redirect alert_uri
  end
end

delete "/delete/*" do |path|
  @memo = Memo.delete(path)
  redirect "/"
end
