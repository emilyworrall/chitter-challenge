require_relative './data_mapper_setup'
require './spec/helpers/timestamper'
require_relative 'helpers'

class Chitter < Sinatra::Base

  include Helpers
  include Timestamper

  set :views, proc {File.join(root,'..','/app/views')}

  use Rack::MethodOverride

  enable :sessions
  set :static, true
  set :root, File.dirname(__FILE__)
  set :session_secret, 'super secret'

  register Sinatra::Flash

  get '/feed' do
    @peeps = Peep.all
    erb :'feed/index'
  end

  get '/feed/new' do
    erb :'feed/new'
  end

  post '/feed' do
    peep = Peep.new(message: params[:message],
                    username: session[:username],
                    name: session[:name])
    peep.save
    redirect ('/feed')
  end

  get '/users/new' do
    @user = User.new
    erb :'users/new'
  end

  post '/users' do
    @user = User.create(email: params[:email],
                        name: params[:name],
                        username: params[:username],
                        password: params[:password],
                        password_confirmation: params[:password_confirmation])
    if @user.save
      session[:user_id] = @user.id
      session[:username] = params[:username]
      session[:name] = params[:name]
      redirect '/feed'
    else
      flash.now[:errors] = @user.errors
      erb :'users/new'
    end
  end

  get '/sessions/new' do
      erb :'sessions/new'
  end

  post '/sessions' do
    user = User.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      redirect '/feed'
    else
      flash.now[:errors] = ['The email or password is incorrect']
      erb :'sessions/new'
    end
  end

  delete '/sessions' do
    session[:user_id] = nil
    redirect '/sessions/goodbye'
  end

  get '/sessions/goodbye' do
    erb :'sessions/goodbye'
  end

end
