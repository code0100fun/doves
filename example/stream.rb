#!/usr/bin/env ruby
require 'highline/import'
require './lib/account'
require './lib/search'

class Cli

  attr_accessor :search, :account, :session

  def initialize
    # TODO - Ask for login info
    @account = Doves::Account.new
    @session = account.login
    @search = Doves::Search.new
  end

  def ask_search
    term = ask 'Enter track search term > '
    tracks = search.query session, term, limit: 10
    Doves::Log.info "Found #{tracks.length} search results"
    select tracks
  end

  def select tracks
    if tracks.length > 0
      if tracks.length > 1
        choose do |menu|
          menu.prompt = "Found multiple tracks. Choose one: "
          tracks.each do |t|
            menu.choice(t.title) do
              account.player.play_track session, t.to_link.to_str
              STDIN.gets
              ask_search
            end
          end
          menu.choice("Search Again") { ask_search }
        end
      else
        account.player.play_track session, tracks.first.to_link.to_str
        STDIN.gets
        ask_search
      end
    end
  end
end

cli = Cli.new
cli.ask_search
Doves::Log.info "Program complete"
