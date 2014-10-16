require 'pdf-reader'

class Motion
  Parts = {
    preamble:    { start: /\A/,               end: /\s*\d+\.\s+Moved by/, replace: /Moved\s+by\s+\w+\s+/ },
    moved_by:    { start: /Moved by/,         end: /Seconded by/,         replace: /Moved\s+by\s+\w+\s+/ },
    seconded_by: { start: /Seconded by/,      end: /[\d\.\s]*that/i,      replace: /Seconded\s+by\s+\w+\s+/ },
    text:        { start: /[\d\.\s]*that/i,   end: /VOTING|CARRIED|DEFEATED/ },
    in_favour:   { start: /VOTING IN FAVOUR/, end: /\(\d+\)/,             replace: /VOTING IN FAVOUR/ },
    against:     { start: /VOTING AGAINST/,   end: /\(\d+\)/,             replace: /VOTING AGAINST/ },
    notes:       { start: /VOTING AGAINST/,   end: /CARRIED|DEFEATED/,    replace: /VOTING AGAINST.*\)/ },
    result:      { start: /CARRIED|DEFEATED/, end: /\z/ },
  }

  def initialize(full_text='')
    @parts = {}

    Parts.each do |name, settings|
      parts[name] = MotionPart.new full_text, settings[:start], settings[:end]
    end
  end

  [:preamble, :moved_by, :seconded_by, :text, :notes, :result].each do |name|
    define_method name do
      part name
    end
  end

  def in_favour
    voters part :in_favour
  end

  def against
    voters part :against
  end

  def unanimous?
    in_favour.empty? || against.empty?
  end

  def inspect
    "Moved by #{moved_by.inspect}\nSeconded by #{seconded_by.inspect}\n#{text.inspect}\nIn favour: #{in_favour.inspect}\nAgainst: #{against.inspect}\nResult #{result.inspect}\nNotes: #{notes.inspect}"
  end

  private

  attr_accessor :parts

  def part(name, replace=nil)
    replace ||= Parts[name][:replace] || //
    parts[name].text.gsub(replace, '').strip
  end

  def voters(text)
    text = text.gsub /(:|Mayor|Councillors?,?|\(\d+\))/, ''
    text = text.gsub /\s+and\s+/, ','
    text.split(/,/).map{|v| v.strip}
  end

  class MotionPart

    attr_reader :full_text, :text

    def initialize full_text, start, stop
      @full_text = full_text

      if index(start) && index(stop)
        @text = full_text.slice(index(start)..index(stop)-1).strip
      else
        @text = ''
      end
    end

    def index(search, offset=0)
      full_text.index(search, offset)
    end

    def inspect
      text
    end
  end
end
