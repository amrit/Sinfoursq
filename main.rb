require 'sinatra/reloader'
require 'sinatra'
require 'json'
require 'omniauth'
require 'omniauth-foursquare'
require 'foursquare2'
require 'quimby'

require 'net/https'

#TODO require 'omniauth-att'
class SinatraApp < Sinatra::Base
  configure do
    set :sessions, true
    set :public_folder, Proc.new { File.join(root, "public") }
  end

  use OmniAuth::Builder do
    #TODO: Never version the configuration stuff, especially not API keys and passwords
    #      Use environment variables for this purpose
    provider :foursquare,
      'FQ4UOTLCSL1IU3RX3GLM3E10RDZK2EFB0I1K5BO3ZX1EAUNM',
      '5EVMUNNAQDZDKORGOSTPPESDHZWX0ZUTLMPSXYGXYCUFCSGE',
      :client_options => { :ssl => { :ca_file => "/opt/local/etc/openssl/ca-bundle.crt" } }
  end

  get '/' do
    erb :login
  end

  get '/auth/:provider/callback' do
    omniauth = request.env['omniauth.auth']
    oauth_token = omniauth['credentials']['token']

    @@client = Foursquare2::Client.new(:oauth_token => oauth_token, :ssl => { :verify => OpenSSL::SSL::VERIFY_PEER, :ca_file => "/opt/local/etc/openssl/ca-bundle.crt" })

    #TODO: Move this in a view
    erb <<-EOS
      <script type=\"text/javascript\">
          jQuery(document).ready(function ($) {
              $('#tabs').tab();
          });
      </script>

      <h1><strong> Welcome, #{omniauth['info']['first_name']} ! </strong></h1>
      <ul id=tabs class=nav nav-tabs data-tabs=tabs>
        <li><a href=/auth/foursquare/callback data-toggle=tab>Venues</a></li>
        <li><a href=/campaign data-toggle=tab>Campaigns</a></li>
        <li><a href=/special data-toggle=tab>Specials</a></li>

      </ul>

      <h2> Managed Venues </h2>

      <pre>#{JSON.pretty_generate(@@client.managed_venues)} </pre>
    EOS
  end

  post '/auth/:provider/callback' do
    require 'foursquare2'
    #TODO: Move this in a view
    erb "<p> #{@@client.user_friends('self', options = {:limit => params[:lim] }) } </p>"
  end

  get '/auth/failure' do
    #TODO: Move this in a view
    erb "<h1>Authentication Failed:</h1><h3>message:<h3> <pre>#{params}</pre>"
  end

  get '/auth/:provider/deauthorized' do
    #TODO: Move this in a view
    erb "#{params[:provider]} has deauthorized this app."
  end

  get '/protected' do
    throw(:halt, [401, "Not authorized\n"]) unless session[:authenticated]
    #TODO: Move this in a view
    erb "<pre>#{request.env['omniauth.auth'].to_json}</pre><hr>
         <a href='/logout'>Logout</a>"
  end

  get '/logout' do
    session[:authenticated] = false
    redirect '/'
  end
end
