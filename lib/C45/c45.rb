require "csv"

def read_file
  CSV.open("public/DaTa_Mau.csv", headers: true, header_converters: :symbol).map{|row| row.to_h}
end

class GainRatio
  attr_accessor :value, :attribute
  def initialize value, attribute
    @value = value
    @attribute = attribute
  end
end

class Node
  attr_accessor :children, :name, :value, :foods, :is_match

  def initialize name = nil, foods = [], value = nil, is_match = true
    @name = name
    @foods = foods
    @value = value
    @is_match = is_match
    @children = []
  end

  def add_children chil
    @children.push *chil
  end
end

class Attribute
  attr_accessor :name, :values
  def initialize name, values
    @name = name || ""
    @values = values || Array.new
  end

  def isValidValue value
    return indexValue(value)
  end

  def indexValue value
    @values.include? value
  end

  def to_s
    name
  end
end

class C45
  attr_accessor :data, :root, :arr_gain_ratios, :attributes

  def initialize
    @data = Food.all
    @s = @data.size.to_f
    @arr_gain_ratios = Array.new
    # @attributes = Condition.all
    # @gioi_tinhs = Attribute.new "gioitinh", @data.map{|food| food[:gioitinh]}.uniq
    # @tinh_trangs = Attribute.new "tinhtrang", @data.map{|food| food[:tinhtrang]}.uniq
    # @xu_huongs = Attribute.new "xuhuong", @data.map{|food| food[:xuhuong]}.uniq
    # @attributes = [@gioi_tinhs, @tinh_trangs, @xu_huongs]
    @attributes = Condition.all
    gain_ratio
    attribute= arr_gain_ratios[0].attribute
    @root = Node.new attribute.name, @data, @arr_gain_ratios[0].value, "True/Flase"
    @root = recursive_tree @root, 0
  end

  def calc_entropy attribute
    entropy = 0.0
    attribute.condition_details.each do |condition_details|
      c = condition_details.food_conditions.match(true).count.to_f
      k = condition_details.food_conditions.match(false).count.to_f
      instance = ((c+k)/@s) * (((-c/(k+c)) * Math.log((c/(k+c)),2))-(((-k/(k+c)) * Math.log((k/(k+c)),2))))
      entropy += instance unless instance.is_a?(Float) && instance.nan?
    end
    entropy
  end

  def gain attribute
    tinh_IS - calc_entropy(attribute)
  end

  def split_info attribute
    split = 0.0
    attribute.condition_details.each do |condition_details|
      c = condition_details.food_conditions.match(true).count.to_f
      k = condition_details.food_conditions.match(false).count.to_f
      instance = (-(c + k) / @s) * (((k + c) / @s) * Math.log(((k + c) / @s), 2)) || 0
      split += instance unless instance.is_a?(Float) && instance.nan?
    end
    split
  end

  def gain_ration attribute
    g = gain(attribute)
    g = 0 if g.is_a?(Float) && g.nan?
    s = split_info(attribute)
    s = 0 if s.is_a?(Float) && s.nan?
    g - s
  end

  def gain_ratio
    @attributes.each do |attribute|
      @arr_gain_ratios.push GainRatio.new(gain_ration(attribute), attribute)
    end
    @arr_gain_ratios = @arr_gain_ratios.sort_by {|gain| gain.value}
  end



  def recursive_tree node, level
    return if level == @arr_gain_ratios.size
    gain_ratio = @arr_gain_ratios[level]
    attribute = gain_ratio.attribute
    if level == 0
      new_root = node
    else
      new_root = Node.new attribute.name, node.foods, gain_ratio.value, "True/Flase"
    end
    attribute.condition_details.each do |value|
      match_foods = node.foods.match_condition value.id
      if match_foods.any?
        m = Node.new( value.value, match_foods, 0, true)
        recursive_tree m, level + 1
        new_root.add_children m if m
      end
      not_match_foods = node.foods.not_match_condition value.id
      if not_match_foods.any?
        nm = Node.new(value.value, not_match_foods, 0, false)
        recursive_tree nm, level + 1
        new_root.add_children nm if nm
      end
    end
    if level > 0 && new_root.children.any?
      node.add_children new_root
    end
    return node
  end

  def make_node name, value, foods
  end

  private
  # def count_total_positives samples
  #   samples.match(true).count.to_f
  # end

  def tinh_IS
    return @tinh_IS if @tinh_IS
    c = @data.is_match(true).count.to_f
    k = @s - c
    @tinh_IS = (-(k/c) * Math.log(k / @s,2) - ((c/@s) * Math.log(c/@s, 2)))
  end
end
