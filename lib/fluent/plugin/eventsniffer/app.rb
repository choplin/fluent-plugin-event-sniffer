require 'sinatra/base'
require 'sinatra/rocketio'
require 'slim'

require_relative 'engine_util'

module Fluent
  module EventSnifferPlugin
    class App < Sinatra::Base
      configure :development do
        require 'sinatra/reloader'
        register Sinatra::Reloader
      end

      register Sinatra::RocketIO
      io = Sinatra::RocketIO

      set :root, File.expand_path('../../../../../', __FILE__)

      current_timer = nil
      current_session = nil

      get '/' do
        @pattern_bookmarks = settings.pattern_bookmarks
        slim :index
      end

      post '/pattern' do
        if not current_timer.nil?
          halt 503
        end

        EngineUtil.sniff(params[:pattern], settings.max_events)

        current_timer = EM::PeriodicTimer.new(1) do
          res = EngineUtil.get_sniffed_results
          $log.debug res
          io.push(:event, res) if res.size > 0
        end
        current_session = params[:rocketio_session]

        status 200
        body ''
      end

      delete '/pattern' do
        if not current_timer.nil?
          current_timer.cancel
          current_timer = nil
          current_session = nil
          EngineUtil.restore
        end
        status 200
        body ''
      end

      io.on :connect do |client|
        $log.debug "new client available - <#{client.session}> type:#{client.type} from:#{client.address}"
      end

      io.on :disconnect do |client|
        $log.debug "disconnect client - <#{client.session}> type:#{client.type} from:#{client.address}"
        if not current_timer.nil? and current_session == client.session
          current_timer.cancel
          current_timer = nil
          current_session = nil
          p 'restore'
          EngineUtil.restore
        end
      end

    end
  end
end
