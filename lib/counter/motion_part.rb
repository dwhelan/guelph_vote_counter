class MotionPart

  attr_reader :text

  def initialize full_text, start_match, end_match
    if start_index = full_text.index(start_match)
      end_index = full_text.index(end_match, start_index)
      @text = full_text.slice(start_index..end_index-1).strip
    else
      @text = ''
    end
  end

  def last_word
    text.split(/\s+/).last
  end

  def inspect
    text
  end
end
