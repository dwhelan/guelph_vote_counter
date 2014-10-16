require 'pdf-reader'
require 'open-uri'

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
    motions_text = minutes.scan /Moved *?by.*?(?:CARRIED|DEFEATED)/m
    motions_text.map{|text| Motion.new text}
  end
end
