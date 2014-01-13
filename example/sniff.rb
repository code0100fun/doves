require 'ffi/pcap'
require 'ffi/packets/constants'
require 'ffi/packets/eth'
require 'redis'

dev = FFI::PCap.device_names[0]
pcap = FFI::PCap::Live.new(:dev => dev, :promisc => true)
pcap.stats
pcap.stats.ps_recv
pcap.datalink.describe

redis = Redis.new
redis.flushdb
pcap.loop() do |this,pkt|
  eth = FFI::Packets::Eth::Hdr.new raw: pkt.body
  mac = eth.src.string
  redis.set(mac, true)
  redis.expire(mac, 5*60)
  puts "#{pkt.time} :: #{mac} -> #{eth.dst.string}"
  redis.keys.each do |key|
    puts "  #{key}"
  end
end
