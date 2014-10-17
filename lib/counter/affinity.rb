class Affinity

  def initialize
    @links = Hash.new(0)
  end

  def add(values)
    pairs(values).each do |pair|
      links[pair] += 1
    end
  end

  def force_field
    ff = { nodes: [], links: [] }

    names.each do |name|
      ff[:nodes] << { name: name, group: 1 }
    end

    links.map do |link, value|
      ff[:links] << { source: names.index(link[0]), target: names.index(link[1]), value: value }
    end

    ff
  end

  private

  attr_reader :links

  def pairs(values)
    values.sort.combination(2).to_a
  end

  def names
    links.keys.flatten.uniq.sort
  end
end
