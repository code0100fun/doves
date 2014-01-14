module Doves
  class Track
    attr_reader :offset, :track
    def initialize track
      FFI::MemoryPointer.new(:int) do |ptr|
        @track = track
        @offset  = Rational(track.read_int, 1000)
      end
    end

    def title
      Spotify.track_name(track)
    end

    def to_link offset = offset
      link = Spotify.link_create_from_track track, offset*1000
      Link.new link
    end
  end
end
