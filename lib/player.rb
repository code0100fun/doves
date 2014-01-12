require "plaything"
require './lib/poll'
require './lib/frame_reader'

module Doves
  class Player
    include Poller
    def play_track(session, uri)
      link = Spotify.link_create_from_string(uri)
      track = Spotify.link_as_track(link)
      poll(session) { Spotify.track_is_loaded(track) }
      Spotify.try(:session_player_play, session, false)
      Spotify.try(:session_player_load, session, track)
      Spotify.try(:session_player_play, session, true)
      @playing = true
      poll(session) { not @playing }
    end

    def streaming_error session, error
      Doves::Log.error("session (player)") { "streaming error %s" % Spotify::Error.explain(error) }
    end

    def start_playback session
      Doves::Log.debug("session (player)") { "start playback" }
      plaything.play
    end

    def stop_playback session
      Doves::Log.debug("session (player)") { "stop playback" }
      plaything.stop
      @playing = false
    end

    def get_audio_buffer_stats session, stats
      stats[:samples] = plaything.queue_size
      stats[:stutter] = plaything.drops
      Doves::Log.debug("session (player)") { "queue size [#{stats[:samples]}, #{stats[:stutter]}]" }
    end

    def music_delivery session, format, frames, num_frames
      if num_frames == 0
        Doves::Log.debug("session (player)") { "music delivery audio discontuity" }
        plaything.stop
        0
      else
        frames = FrameReader.new(format[:channels], format[:sample_type], num_frames, frames)
        consumed_frames = plaything.stream(frames, format.to_h)
        Doves::Log.debug("session (player)") { "music delivery #{consumed_frames} of #{num_frames}" }
        consumed_frames
      end
    end

    def end_of_track session
      Doves::Log.debug("session (player)") { "end of track" }
      plaything.stop
      @playing = false
    end

    def plaything
      @_plaything ||= Plaything.new
    end
  end
end
