require 'csv'
require 'pdf-reader'

class Motion
  Parts = {
    preamble:    { start: /\A/,                        stop: /Moved by/,            replace: /\s*\d+\.\z/ },
    moved_by:    { start: /Moved by/,                  stop: /Seconded by/,         replace: /Moved\s+by\s+\w+\s+/ },
    seconded_by: { start: /Seconded by/,               stop: /[\d\.\s]*that/i,      replace: /Seconded\s+by\s+\w+\s+/ },
    text:        { start: /[\d\.\s]*That/,             stop: /VOTING|CARRIED|DEFEATED|Deferral/ },
    in_favour:   { start: /VOTING IN FAVOUR/,          stop: /\(\d+\)/,             replace: /VOTING IN FAVOUR/ },
    against:     { start: /VOTING AGAINST/,            stop: /\(\d+\)/,             replace: /VOTING AGAINST/ },
    notes:       { start: /VOTING AGAINST/,            stop: /CARRIED|DEFEATED/,    replace: /VOTING AGAINST.*\)/ },
    result:      { start: /CARRIED|DEFEATED|Deferral/, stop: /\z/,                  replace: /Deferral/, with: 'DEFERRED'},
  }

  attr_reader :text

  def initialize(text='')
    @text = text
    @parts = {}

    Parts.each do |name, settings|
      parts[name] = MotionPart.new text, settings[:start], settings[:stop]
    end
  end

  [:preamble, :moved_by, :seconded_by, :text, :notes, :result].each do |name|
    define_method(name) { part name }
  end

  [:in_favour, :against].each do |name|
    define_method(name) { voters name }
  end

  def unanimous?
    in_favour.empty? || against.empty?
  end

  def contested?
    ! unanimous?
  end

  def inspect
    "Preamble: #{preamble}\nMoved by #{moved_by.inspect}\nSeconded by #{seconded_by.inspect}\n#{text.inspect}\nIn favour: #{in_favour.inspect}\nAgainst: #{against.inspect}\nResult #{result.inspect}\nNotes: #{notes.inspect}"
  end

  private

  attr_accessor :parts

  def part(name)
    replace = Parts[name][:replace] || //
    with    = Parts[name][:with]    || ''
    parts[name].text.gsub(replace, with).strip
  end

  def voters(name)
    text = remove_titles(part(name))
    text = remove_and(text)
    text = remove_blanks(text)
    text = add_missing_commas(text)
    to_name_array(text)
  end

  def remove_titles(text)
    text.gsub(/(:|Mayor|Council+ors?,?|\(\d+\))/m, '')
  end

  def remove_and(text)
    text.gsub(/and\s+/m, ',').gsub(/hofl,/mi, 'Hofland,')
  end

  def remove_blanks(text)
    text.gsub(/\s*,\s*/m, ',').gsub(/,+/m, ',')
  end

  def add_missing_commas(text)
    text.gsub(/(\w+)\s+(\w+)/m, '\1,\2').gsub(/van,(\w+)/mi, 'Van \1')
  end

  def to_name_array(text)
    CSV.parse(text).flatten.compact.map{|v| v.strip}
  end

  class MotionPart

    def initialize(full_text, start, stop)
      @full_text = full_text
      @start     = start
      @stop      = stop
    end

    def text
      @text ||= start_index && stop_index ? full_text.slice(start_index...stop_index).strip : ''
    end

    def inspect
      text
    end

    private

    attr_reader :full_text, :start, :stop

    def start_index
      @start_index = full_text.index(start)
    end

    def stop_index
      @stop_index = full_text.index(stop, start_index)
    end
  end
end
