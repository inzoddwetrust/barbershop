require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def get_db
	db = SQLite3::Database.new './public/main.db'
	db.results_as_hash = true
	return db
end

def is_barber_exist? db, master
	db.execute('SELECT * FROM Masters WHERE master=?',[master]).length > 0
end

def seed_db db, barbers
	barbers.each do |barber|
		if !is_barber_exist? db, barber
			db.execute 'INSERT INTO Masters (master) values (?)', [barber]
		end
	end
end

def input_errors? hh
		@error = hh.select{|key| params[key] == ""}.values.join(", then ").capitalize
		if @error == ''
			@error = nil
			return false
		else
			return true
		end
end

configure do
	db = get_db
	db.execute 'CREATE TABLE IF NOT EXISTS
							"Users"
							( "id" INTEGER PRIMARY KEY AUTOINCREMENT,
								"username" TEXT,
								"phone" TEXT,
								"datestamp" TEXT,
								"master" TEXT,
								"color" TEXT )'
	db.execute 'CREATE TABLE IF NOT EXISTS
							"Contacts"
							( "id" INTEGER PRIMARY KEY AUTOINCREMENT,
								"email" TEXT,
								"message" TEXT,
								"sendtime" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL)'
	db.execute 'CREATE TABLE IF NOT EXISTS
							"Masters"
							( "id" INTEGER PRIMARY KEY AUTOINCREMENT,
								"master" TEXT)'
	seed_db db, ['Jessie Pinkman', 'Walter White', 'Gus Fring', 'Zodd Zverev']
end

before do
	db=get_db
	@master_list = db.execute 'SELECT * FROM Masters'
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

	db=get_db

	if @login == "admin" && @password == "secret"
		@entry = db.execute 'SELECT * FROM Users ORDER by datestamp'
		@message = db.execute 'SELECT * FROM Contacts ORDER by sendtime desc'
	else
		@entry=nil
		@message=nil
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

	db=get_db

	return erb :visit if input_errors? hh

	db.execute 'INSERT INTO Users (username, phone, datestamp, master, color) VALUES (?, ?, ?, ?, ?)', [@username, @phone, @time, @master, @color]

	erb "<div class='alert alert-success'>Thanks #{@username}! #{@master} is waiting you at #{@time}.</div>"
end

post '/contacts' do
	@email = params[:email]
	@text = params[:text]

	db=get_db

	hh = {:email => 'Enter your e-mail',
				:text => 'Enter your message',
				}

	return erb :contacts if input_errors? hh

	db.execute 'INSERT INTO Contacts (email, message) VALUES (?, ?)', [@email, @text]

	erb "<div class='alert alert-success'>Thanks! We will answer you to #{@email} soon.</div>"
end
