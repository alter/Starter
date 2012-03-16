require 'rubygems'
require 'sinatra'
require 'haml'
set :haml, :format => :html5
@@result = ""
get '/' do
    haml :index
end

post '/' do
    territory   = params[:territory]
    version     = params[:version]
    job         = params[:job]
    server      = params[:server]
        
    Process.detach(fork{@@result = %x[/usr/bin/python /home/a1/GPT_launcher/launcher.py --job #{job} --config #{server} --territory #{territory} --version #{version}]
    puts @@result
    })
    puts @@result
    haml :index
    redirect '/success' 
end

get '/success' do
    haml :success, :locals => {:result => @@result }
end
