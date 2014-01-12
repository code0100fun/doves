require 'singleton'
require 'logger'
require 'active_support/all'

module Doves
  class Log
    include Singleton

    delegate :info, :debug, :error, :to => :logger

    attr_reader :logger

    def initialize
      $stderr.sync = true
      @logger = Logger.new($stderr)
      @logger.level = Logger::INFO
    end

    class << self
      delegate :info, :debug, :error, :to => :instance
    end
  end
end
