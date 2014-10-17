class Affinity

  def initialize
    @links = Hash.new(0)
    @groups = Hash.new(0)
  end

  def add_group(*names)
    group = groups.values.uniq.count+1
    names.flatten.each do |name|
      groups[name] = group
    end
  end

  def add(values)
    pairs(values).each do |pair|
      fail if pair[0].empty? || pair[1].empty?
      links[pair] += 1
    end
  end

  def force_field(options=default_options)
    result = { nodes: [], links: [] }

    names = links.keys.flatten.uniq.sort

    names.each do |name|
      result[:nodes] << { name: name, group: groups[name] }
    end

    filtered_links(options).map do |link, value|
      result[:links] << { source: names.index(link[0]), target: names.index(link[1]), value: value }
    end

    result
  end

  def filtered_links(options)
    links.select{|k,v| v >= options[:min]}
  end

  def default_options
    { min: 0 }
  end
  private

  attr_reader :links, :groups

  def pairs(values)
    values.sort.combination(2).to_a
  end
end
