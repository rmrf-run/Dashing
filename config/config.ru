$: << File.expand_path('./lib', File.dirname(__FILE__))
require 'dashing-contrib'
require 'dashing'
DashingContrib.configure

configure do
  set :auth_token, 'xJCv8zuek6UoSgCgaT89'

  helpers do
    def protected!
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
