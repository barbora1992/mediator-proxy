require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/content_for'
require 'sinatra/namespace'
require 'sinatra/contrib/all'
require 'yaml'
require 'sinatra/base'
require 'sinatra/flash'
require 'securerandom'
require 'pry'
require 'logger' 
require "sinatra/streaming"

require_relative "task"
require_relative "taskqueue"

set :bind, '0.0.0.0'
enable :logging #works
#set :logger #nope

logger = Logger.new('/tmp/app.error.log')
buffer = TaskQueue.new


##################################WEBUI######################################################

get '/' do 
  erb :webui
end

get "/features" do 
  logger.info('listing features')	        
  '["logs","puppetca"]'
end

get "/version" do 
  logger.info('listing version')
  '{"version":"1.14.0-develop","modules":{"puppetca":"1.14.0","logs":"1.14.0"}}' #imaginary
end

get "/logs/" do #TODO it just doesnt want to work - it used to, but now it doesnt
  logger.info('listing logs')
  content_type :json 
  #logger.to_json
  #binding.pry 
  {"logs": logger.to_json }
  #'{}'
end

get '/clear' do #delete 'tasks'
  buffer.clear
  erb :success
end

get '/tasks' do #get 'tasks'
  erb :list, :locals => { :buffer => buffer } 
end

get '/file' do 
  buffer.each do |task|  
    task.status = "saved" #TODO this stopped working since the Task/TaskQueue classes were separated
  end
  content_type 'plain/text'
  attachment "tasks.yaml"
  buffer.to_yaml
end

get '/deleteuuid' do 
  erb :deleteuuid
end

post '/deletetaskuuid' do 
  u = params[:uuid]
  buffer.delete_task_by_uuid(u)
  redirect '/'
end

get '/preload' do 
  t = Task.new("/puppet/ca","get", nil)
  buffer.enqueue(t)
  s = Task.new("/puppet/ca/autosign","get", nil) 
  buffer.enqueue(s)
  redirect '/'
end

###############################PUPPETCA#####################################################

get "/puppet/ca" do 
  logger.info('Failed to list certificates')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca","get", nil)
  buffer.enqueue(t)
  "{}" #this works
end

get "/puppet/ca/autosign" do #list of all puppet autosign entires
  logger.info('Failed to list puppet autosign entries')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca/autosign","get", nil)
  buffer.enqueue(t)
  "{}" #this works
end

post "/puppet/ca/autosign/:certname" do #Add certname to Puppet autosign
  arr = params[:certname]
  logger.info('Failed to add certname to Puppet autosign')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca/autosign/"+arr,"post", arr)
  buffer.enqueue(t)
  content_type 'application/json' #thats how smart-proxy replies
  response.status = 404
end

delete "/puppet/ca/autosign/:certname" do #Remove certname from Puppet autosign	
  arr = params[:certname]
  logger.info('Failed to delete certname from Puppet autosign')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca/autosign/"+arr,"delete", arr)
  buffer.enqueue(t)
  content_type 'application/json'
  response.status = 404
end

post "/puppet/ca/:certname" do #Sign pending certificate request
  arr = params[:certname]
  logger.info('Failed to sign certname')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca/"+arr,"post", arr)
  buffer.enqueue(t)
  content_type 'application/json'
  response.status = 404
end

delete "/puppet/ca/:certname" do #Remove (clean) and revoke a certificate
  arr = params[:certname]
  logger.info('Failed to delete certname')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca/"+arr,"delete", arr)
  buffer.enqueue(t)
  content_type 'application/json'
  response.status = 404
end

