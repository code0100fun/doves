require 'timeout'
require './lib/link'
require './lib/track'
require './lib/tracks'

module Doves
  class Search

    def query session, term, options
      Doves::Log.info "Searching '#{term}'"
      limit = options[:limit] || 10
      opts = [0,limit,0,0,0,0,0,0]
      tracks = nil
      callback = proc do |search, data|
        Doves::Log.info "Search complete!"
        tracks = Tracks.new search
      end
      search = Spotify.search_create session, term, *opts, :standard, callback, nil
      load session, search
      tracks
    end

    def process_events session
      FFI::MemoryPointer.new(:int) do |p|
        Spotify.session_process_events(session, p)
        return p.read_int
      end
    end

    def load session, search
      Timeout.timeout(5) do
        until Spotify.search_is_loaded(search)
          process_events session
          status = Spotify.search_error(search)
          Doves::Log.debug "Search status: #{status}"
          raise status if status && status != :is_loading && status != :ok
          sleep(0.001)
        end
      end
    end

  end
end
