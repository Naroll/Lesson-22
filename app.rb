require 'sinatra'
require 'rubygems'
require "sinatra/reloader"
require 'pony'

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
  @error = 'something wrong!'
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

  #Добавляем хэш с сообщениями об ошибках
  hh = { :username => 'Введите имя', :phone => 'Введите телефон', :datetime => 'Введите дату'}

  #Формирование сообщения об ошибке
  @error = hh.select {|key,_| params[key] == ''}.values.join(', ')

  if @error !=''
    return erb :visit 
  end

  f = File.open './public/users.txt', 'a'
  #chmod 666 users.txt
  f.write "User: #{@username}, phone: #{@phone}, date and time #{@datetime}, master #{@mastername}\n"
  f.close
  redirect '/visit'
end

get '/contacts' do
  erb :contacts
end

post '/contacts' do
  @email = params[:email]
  @message = params[:message]

  hh = { :email => 'Введите ваш email', :message => 'Введите ваше сообщение'}

  #Формирование сообщения об ошибке
  @error = hh.select {|key,_| params[key] == ''}.values.join(', ')

  if @error !=''
    return erb :contacts
  end

  #Запись в файл contcts.txt
  #f = File.open './public/contacts.txt', 'a'
  #chmod 666 users.txt
  #f.write "E-mail: #{@email}, message: #{@message}\n"
  #f.close

  #Отправка сообщения на e-mail

  Pony.mail({
  :body => params[:message],
  :to => 'zge8858@gmail.com',
  :via => :smtp,
  :via_options => {
    :address              => 'smtp.gmail.com',
    :port                 => '587',
    :enable_starttls_auto => true,
    :user_name            => 'zge8858@gmail.com',
    :password             => 'niber200487',
    :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
    :domain               => "localhost.localdomain" # the HELO domain provided by the client to the server
  }
})

  redirect '/contacts'
end