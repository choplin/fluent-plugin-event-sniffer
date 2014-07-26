require 'thin'

module Fluent
  class EventSniffer < Input
    Plugin.register_input('event_sniffer', self)

    config_param :bind, :string, :default => '0.0.0.0'
    config_param :port, :integer, :default => 8765
    config_param :access_log_path, :string, :default => nil

    config_param :pattern_bookmarks, :array, :default => []
    config_param :max_events, :integer, :default => 10
    config_param :refresh_interval, :integer, :default => 1

    config_param :development, :bool, :default => false

    def start
      super

      $log.info "listening http server for event_sniffer on http://#{@bind}:#{@port}"

      @access_log = File.open(@access_log_path, 'a') if @access_log_path

      config = {
        development: @development,
      }
      app = Rack::Builder.new do
        ENV['RACK_ENV'] = config[:development] ? 'development' : 'production'
        require_relative 'eventsniffer/app'
        run EventSnifferPlugin::App.new
      end

      EventSnifferPlugin::App.set :pattern_bookmarks, @pattern_bookmarks
      EventSnifferPlugin::App.set :max_events, @max_events
      EventSnifferPlugin::App.set :refresh_interval, @refresh_interval

      options = {
        signals: false,
      }
      @srv = ::Thin::Server.new(@bind, @port, app, options)
      @thread = Thread.new { @srv.start }
    end

    def shutdown
      super

      if @srv
        @srv.stop
        @srv = nil
      end

      if @access_log and (not @access_log.closed?)
        @access_log.close
      end

      if @thread
        @thread.join
        @thread = nil
      end
    end
  end
end
