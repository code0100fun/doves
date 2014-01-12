require 'spotify'
require 'yaml'
require './lib/player'
require './lib/log'
require './lib/poll'

module Doves
  class Account
    include Poller
    def app_key
      IO.read("./.spotify_appkey.key", encoding: "BINARY")
    end

    def credentials
      @_credentials ||= YAML.load_file './.spotify_credentials.yaml'
    end

    def username
      credentials['SPOTIFY_USERNAME']
    end

    def password
      credentials['SPOTIFY_PASSWORD']
    end

    def blob= blob
      File.open(blob_file, 'w+') {|f| f.write({'SPOTIFY_BLOB' => blob}.to_yaml) }
      @_blob = blob
    end

    def blob
      if File.exists? blob_file
        puts 'blob exists'
        @_blob ||= YAML.load_file(blob_file)['SPOTIFY_BLOB']
        puts @_blob
        @_blob
      end
    end

    def blob_file
      './.spotify_blob.yaml'
    end

    def player
      @_player ||= Player.new
    end

    def config
      @_config ||= Spotify::SessionConfig.new({
        api_version: Spotify::API_VERSION.to_i,
        application_key: app_key,
        cache_location: ".spotify/",
        settings_location: ".spotify/",
        user_agent: "spotify for ruby",
        callbacks: callbacks
      })
    end

    def callbacks
      Spotify::SessionCallbacks.new(callbacks_hash)
    end

    def callbacks_hash
      {
        log_message: Proc.new do |session, message|
          Doves::Log.info("session (log message)") { message }
        end,
        logged_in: method(:logged_in),
        logged_out: method(:logged_out),
        credentials_blob_updated: method(:credentials_blob_updated),
        streaming_error: player.method(:streaming_error),
        start_playback: player.method(:start_playback),
        stop_playback: player.method(:stop_playback),
        get_audio_buffer_stats: player.method(:get_audio_buffer_stats),
        music_delivery: player.method(:music_delivery),
        end_of_track: player.method(:end_of_track)
      }
    end

    def logged_in session, error
      Doves::Log.debug("session (logged in)") { Spotify::Error.explain(error) }
    end

    def logged_out session
      Doves::Log.debug("session (logged out)") { "logged out!" }
    end

    def credentials_blob_updated session, blob
      Doves::Log.info('session (blob)') { self.blob = blob }
    end

    def session
      @_session ||= create_session
    end

    def create_session
      Doves::Log.info "Creating session."
      FFI::MemoryPointer.new(Spotify::Session) do |ptr|
        Spotify.session_create config, ptr
        return Spotify::Session.new(ptr.read_pointer)
      end
      Doves::Log.info "Created session!"
    end

    def login
      unless blob.nil?
        Doves::Log.info "Logging in with blob: #{blob}"
        Spotify.session_login(session, username, nil, false, blob)
      else
        Doves::Log.info "Logging in: #{username}:#{password}"
        Spotify.session_login(session, username, password, false, nil)
      end
      Doves::Log.info "Log in requested. Waiting forever until logged in."
      poll(session) { Spotify.session_connectionstate(session) == :logged_in }
      Doves::Log.info "Logged in as #{Spotify.session_user_name(session)}."
      session
    end

  end
end
