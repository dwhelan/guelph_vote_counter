require 'pdf-reader'
require 'open-uri'

class Meeting

  attr_reader :minutes_url

  def initialize(minutes_url)
    @minutes_url = minutes_url
  end

  def date
    match = minutes_url.match  /.*(\d\d)(\d\d)(\d\d)\.pdf\z/i
    month = match[1].to_i
    day   = match[2].to_i
    year  = match[3].to_i + 2000
    Date.new year, month, day
  end

  def minutes
    @minutes ||= begin
      io     = open(minutes_url)
      reader = PDF::Reader.new(io)
      reader.pages.map(&:text).join(' ')
    end
  end

  def motions
    motions_text = minutes.scan /Moved *?by.*?(?:CARRIED|DEFEATED)/m
    motions_text.map{|text| Motion.new text}
  end
end
