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

    alias_method :from_file, :from_url

    def from_text(text)
      Meeting.new text
    end
  end

  def initialize(text)
    @text = text
    date
    clean
  end

  def date
    @date ||= begin
      match = text.match /\w+\s+\d+,\s*\d{4}/m
      Date.strptime(match[0], '%B %d, %Y') if match
    end
  end

  def motions
    scanner = StringScanner.new text

    motions=[]
    while motion_text = scanner.scan(/(.*?(CARRIED|DEFEATED|Deferral))/m)
      motions << Motion.new(motion_text)
    end
    motions
  end

  private

  def clean
    text.gsub! /.*Call to Order.*?\n/mi, ' '
    text.gsub! /\s*\w+\s+\d+,\s+\d{4}\s+Guelph City Council Meeting\s*/, ' '
    text.gsub! /\s*Page\s+\d*\s*/, ' '
    text.gsub! /\s+/, ' '
  end
end
