#!/usr/bin/env ruby
require './lib/account'
require './lib/search'

account = Doves::Account.new
session = account.login

search = Doves::Search.new
print 'Enter track search term > '
term = STDIN.gets
tracks = search.query session, term
Doves::Log.info "Found #{tracks.length} search results"

if tracks.length > 0
  account.player.play_track session, tracks.first.to_link.to_str
  STDIN.gets
end
Doves::Log.info "Program complete"
