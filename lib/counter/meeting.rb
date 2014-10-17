require 'pdf-reader'
require 'open-uri'
require 'strscan'

class Meeting

  attr_reader :minutes

  class << self
    def from_minutes(minutes_url)
      io     = open(minutes_url)
      reader = PDF::Reader.new(io)
      minutes = reader.pages.map(&:text).join(' ')
      Meeting.new minutes
    end
  end

  def initialize(minutes)
    @minutes = minutes
  end

  def date
    match = minutes.match /\w+\s+\d+,\s*\d{4}/m
    Date.strptime(match[0], '%B %d, %Y') if match
  end

  def motions

    scanner = StringScanner.new minutes.sub(/.*Call to Order.*?\\n/i, '')

    motions=[]
    while text = scanner.scan(/(.*?(CARRIED|DEFEATED|Deferral))/m)
      motions << Motion.new(text)
    end
    motions
  end
end
