module Doves
  class Tracks
    include Enumerable
    def initialize search
      @search = search
    end

    def search
      @search
    end

    def length
      Spotify.search_num_tracks search
    end

    def [] index
      at index
    end

    def at index
      item = Spotify.search_track search, index
      Track.new item
    end

    def each
      index = 0
      while index < length
        yield self[index]
        index += 1
      end
      self
    end
  end

end
