require 'pdf-reader'
require 'open-uri'
require 'strscan'

class Meeting

  attr_reader :text

  class << self
    def from_url(minutes_url)
      io     = open(minutes_url)
      reader = PDF::Reader.new(io)
      text = reader.pages.map(&:text).join(' ')
      from_text text
    end

    def from_text(text)
      Meeting.new text
    end
  end

  def initialize(text)
    @text = text
    clean
  end

  def date
    match = text.match /\w+\s+\d+,\s*\d{4}/m
    Date.strptime(match[0], '%B %d, %Y') if match
  end

  def motions
    scanner = StringScanner.new text.sub(/.*Call to Order.*?\\n/i, '')

    motions=[]
    while text = scanner.scan(/(.*?(CARRIED|DEFEATED|Deferral))/m)
      motions << Motion.new(text)
    end
    motions
  end

  private

  def clean
    text.gsub! /\s*\w+\s+\d+,\s+\d{4}\s+Guelph City Council Meeting\s*/, ' '
    text.gsub! /\s*Page\s+\d*\s*/, ' '
  end
end
