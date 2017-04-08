require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

def file_read file
	f = File.open file
	while (line=f.gets)
		@entry=@entry+line+"<br>"
	end
	f.close
end

def input_errors? hh
		@error = hh.select {|key| params[key] == ""}.values.join(", then ").downcase.capitalize
		if @error == ''
			@error = nil
			return false
		else
			return true
		end
end

get '/' do
	erb :index
end

get '/about' do
	erb :about
end

get '/visit' do
	erb :visit
end

get '/contacts' do
	erb :contacts
end

post '/' do
	@login = params[:login]
	@password = params[:password]

	hh = {:login => 'Enter login',
				:password => 'Enter password',
				}

	return erb :index if input_errors? hh

	if @login == "admin" && @password == "secret"
		@entry="<label>Booked:</label><br><br>"
		file_read "./public/users.txt"
		@entry=@entry+"<br>"+"<br>"+"<label>Questions:</label>"+"<br>"
		file_read "./public/questions.txt"
	else
		@entry='<div class="alert alert-danger">ACCESS DENIED</div>'
	end

	erb :admin
end


post '/visit' do
	@username = params[:username]
	@phone = params[:phone]
	@time = params[:time]
	@master = params[:master]
	@color = params[:color]

	hh = {:username => 'Enter name',
				:phone => 'Enter phone',
				:time => 'Enter time'
				}

	return erb :visit if input_errors? hh

	f = File.open "./public/users.txt", "a"
	f.write "User: #{@username}, Phone: #{@phone}, Time: #{@time}, Master: #{@master}, Color: #{@color}\n"
	f.close

	erb "<div class='alert alert-success'>Thanks #{@username}! #{@master} is waiting you at #{@time}.</div>"
end

post '/contacts' do
	@email = params[:email]
	@text = params[:text]

	hh = {:email => 'Enter your e-mail',
				:text => 'Enter your message',
				}

	return erb :contacts if input_errors? hh

	f = File.open "./public/questions.txt", "a"
	f.write "\nE-mail: #{@email},\n\nText:\n#{@text}\n==============="
	f.close

	erb "<div class='alert alert-success'>Thanks! We will answer you to #{@email} soon.</div>"
end
