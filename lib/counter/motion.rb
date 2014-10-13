require 'pdf-reader'

class Motion
  Parts = [
    { name: :moved_by,    start: /\A/,               end: /Seconded by/},
    { name: :seconded_by, start: /Seconded by/,      end: /[\d\.\s]*that/i },
    { name: :text,        start: /[\d\.\s]*that/i,   end: /VOTING|CARRIED|DEFEATED/ },
    { name: :in_favour,   start: /VOTING IN FAVOUR/, end: /\(\d+\)/ },
    { name: :against,     start: /VOTING AGAINST/,   end: /\(\d+\)/ },
    { name: :notes,       start: /VOTING AGAINST/,   end: /CARRIED|DEFEATED/ },
    { name: :result,      start: /CARRIED|DEFEATED/, end: /\z/ },
  ]

  def initialize(full_text)
    @parts = {}

    Parts.map do |part|
      parts[part[:name]] = MotionPart.new full_text, part[:start], part[:end]
    end
  end

  def moved_by
    parts[:moved_by].last_word
  end

  def seconded_by
    parts[:seconded_by].last_word
  end

  def text
    parts[:text].text
  end

  def in_favour
    voters parts[:in_favour].text.gsub /VOTING IN FAVOUR/, ''
  end

  def against
    voters parts[:against].text.gsub /VOTING AGAINST/, ''
  end

  def notes
    parts[:notes].text.gsub(/VOTING AGAINST.*\)/, '').strip
  end

  def result
    parts[:result].text
  end

  def inspect
    "Moved by #{moved_by.inspect}\nSeconded by #{seconded_by.inspect}\n#{text.inspect}\nIn favour: #{in_favour.inspect}\nAgainst: #{against.inspect}\nResult #{result.inspect}\nNotes: #{notes.inspect}"
  end

  private

  attr_accessor :parts

  def voters(text)
    text = text.gsub /(:|Mayor|Councillors?,?|\(\d+\))/, ''
    text = text.gsub /\s+and\s+/, ','
    text.split(/,/).map{|v| v.strip}
  end
end
