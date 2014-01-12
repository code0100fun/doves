module Doves
  module Poller
    def poll(session, idle_time = 0.01)
      until yield
        FFI::MemoryPointer.new(:int) do |ptr|
          Spotify.session_process_events(session, ptr)
        end
        sleep(idle_time)
      end
    end
  end
end
