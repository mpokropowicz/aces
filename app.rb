require "sinatra"
require "pg"
require_relative "add_form.rb"
require_relative "return_data.rb"

get "/" do 

	erb :starter
end

get '/commit_form' do

  add_form(request.env['rack.request.query_hash'])

  redirect to '/'
end

get '/search' do
  erb :search
end

post '/search_results' do
  value = params[:name]
  results = pull_records(value)  # get array of hashes for all matching records
  feedback = results[0]["name"]
  if feedback == "No matching record - please try again."
    erb :search, locals: {feedback: feedback}
  else
    erb :search_results, locals: {results: results}
  end
end

post '/update_form' do
  vals = params[:vars].split("&")
  #user_hash = get_data(vals[vals.index{|s| s.include?("id")}].sub("id=", ""))
  erb :update_form, :locals => {results: vals}
end

get'/commit_updates' do
  user_hash = params[:user]
  update_values(user_hash)
  # user_hash = get_data(id)
  # update_values(user_hash)

  "#{user_hash}"
end