module Doves
  class Link
    def initialize link
      @link = link
    end

    def link
      @link
    end

    def length
      Spotify.link_as_string(link, nil, 0)
    end

    def to_str(length = length)
      FFI::Buffer.alloc_out(length + 1) do |b|
        Spotify.link_as_string(link, b, b.size)
        return b.get_string(0).force_encoding("UTF-8")
      end
    end

    def to_url
      "http://open.spotify.com/%s" % to_str[8..-1].gsub(':', '/')
    end

  end
end
