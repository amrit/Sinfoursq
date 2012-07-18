require 'rubygems'
require 'sinatra'
require 'json'
require 'omniauth'
require 'omniauth-foursquare'
require 'foursquare2'
require 'quimby'
require 'net/https'

#<pre>#{JSON.pretty_generate(request.env['omniauth.auth'])}</pre>
#TODO require 'omniauth-att'

class SinatraApp < Sinatra::Base
  configure do
    set :sessions, true
    set :inline_templates, true
  end
  use OmniAuth::Builder do
    
    provider :foursquare, 'FQ4UOTLCSL1IU3RX3GLM3E10RDZK2EFB0I1K5BO3ZX1EAUNM','5EVMUNNAQDZDKORGOSTPPESDHZWX0ZUTLMPSXYGXYCUFCSGE',
    :client_options => {:ssl => {:ca_file => '/opt/local/etc/openssl/ca-bundle.crt'}}

    #provider :att, 'client_id', 'client_secret', :callback_url => (ENV['BASE_DOMAIN']

  end
  
  get '/' do
    erb "
    <a href='http://localhost:4567/auth/foursquare'>Login with Foursquare</a><br>"
  
  end
  
  get '/auth/:provider/callback' do
    
    omniauth = request.env['omniauth.auth']   
    oauth_token = omniauth['credentials']['token']
    
    client = Foursquare2::Client.new(:oauth_token => 'oauth_token')
    
    c = client.user('self')
    
    
    
    
    
    
    
    
    erb "<h1>#{c}</h1>"
         
   
      
      
  end
  
  get '/auth/failure' do
    erb "<h1>Authentication Failed:</h1><h3>message:<h3> <pre>#{params}</pre>"
  end
  
  get '/auth/:provider/deauthorized' do
    erb "#{params[:provider]} has deauthorized this app."
  end
  
  get '/protected' do
    throw(:halt, [401, "Not authorized\n"]) unless session[:authenticated]
    erb "<pre>#{request.env['omniauth.auth'].to_json}</pre><hr>
         <a href='/logout'>Logout</a>"
  end
  
  get '/logout' do
    session[:authenticated] = false
    redirect '/'
  end

end

SinatraApp.run! if __FILE__ == $0

__END__

@@ layout
<html>
  <head>
    <link href='http://twitter.github.com/bootstrap/1.4.0/bootstrap.min.css' rel='stylesheet' />
  </head>
  <body>
    <div class='container'>
      <div class='content'>
        <%= yield %>
      </div>
    </div>
  </body>
</html>
