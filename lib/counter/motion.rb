require 'pdf-reader'

class Motion
  Parts = [
    { name: :preamble,    start: /\A/,               end: /\s*\d+\.\s+Moved by/, replace: /Moved\s+by\s+\w+\s+/},
    { name: :moved_by,    start: /Moved by/,         end: /Seconded by/},
    { name: :seconded_by, start: /Seconded by/,      end: /[\d\.\s]*that/i },
    { name: :text,        start: /[\d\.\s]*that/i,   end: /VOTING|CARRIED|DEFEATED/ },
    { name: :in_favour,   start: /VOTING IN FAVOUR/, end: /\(\d+\)/ },
    { name: :against,     start: /VOTING AGAINST/,   end: /\(\d+\)/ },
    { name: :notes,       start: /VOTING AGAINST/,   end: /CARRIED|DEFEATED/ },
    { name: :result,      start: /CARRIED|DEFEATED/, end: /\z/ },
  ]

  def initialize(full_text=nil)
    full_text ||= ''
    @parts = {}

    Parts.map do |part|
      parts[part[:name]] = MotionPart.new full_text, part[:start], part[:end]
    end
  end

  def preamble
    part :preamble
  end

  def moved_by
    part :moved_by, /Moved\s+by\s+\w+\s+/
  end

  def seconded_by
    part :seconded_by, /Seconded\s+by\s+\w+\s+/
  end

  def text
    part :text
  end

  def in_favour
    voters part(:in_favour, /VOTING IN FAVOUR/)
  end

  def against
    voters part(:against, /VOTING AGAINST/)
  end

  def notes
    part :notes, /VOTING AGAINST.*\)/
  end

  def result
    part :result
  end

  def unanimous?
    in_favour.empty? || against.empty?
  end

  def inspect
    "Moved by #{moved_by.inspect}\nSeconded by #{seconded_by.inspect}\n#{text.inspect}\nIn favour: #{in_favour.inspect}\nAgainst: #{against.inspect}\nResult #{result.inspect}\nNotes: #{notes.inspect}"
  end

  private

  attr_accessor :parts

  def part(name, replace=//)
    parts[name].text.gsub replace, ''
  end

  def voters(text)
    text = text.gsub /(:|Mayor|Councillors?,?|\(\d+\))/, ''
    text = text.gsub /\s+and\s+/, ','
    text.split(/,/).map{|v| v.strip}
  end
end
