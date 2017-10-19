require 'sinatra'
require 'rubygems'
require "sinatra/reloader"

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/about' do
  erb :about
end

get '/visit' do
  erb :visit
end

post '/visit' do
  @mastername = params[:mastername]
  @username = params[:username]
  @phone = params[:phone]
  @datetime = params[:datetime]

  f = File.open './public/users.txt', 'a'
  #chmod 666 users.txt
  f.write "User: #{@username}, phone: #{@phone}, date and time #{@datetime}, master #{@mastername}\n"
  f.close
  erb :visit
end

get '/contacts' do
  erb :contacts
end

post '/contacts' do
  @email = params[:email]
  @message = params[:message]

  f = File.open './public/contacts.txt', 'a'
  #chmod 666 users.txt
  f.write "E-mail: #{@email}, message: #{@message}\n"
  f.close
  erb :contacts
end