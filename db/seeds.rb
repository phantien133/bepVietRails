puts "---------------------"
puts "Create base Category"
c = Category.create! name: "BASE CATEGORY", left: 1, right: 2
  5.times do |n|
    s = Category.add! Faker::Name.name, c.right
      5.times do
        Category.add! Faker::Name.name, s.right
        s.reload
      end
    c.reload
  end

puts "---------------------"
puts "Create Condition"
c = Condition.create! name: "Illness"
5.times do |n|
  c.condition_details.create! value: "Bệnh #{ n+ 1}"
end
c1 = Condition.create! name: "Gender"
c1.condition_details.create! value: "Female"
c1.condition_details.create! value: "Male"
c2 = Condition.create! name: "Tendency"
c2.condition_details.create! value: "Up"
c2.condition_details.create! value: "Down"

puts "---------------------"
puts "Create food"
50.times do |n|
  food = Food.create! name: Faker::Name.name, cooking_method: Faker::Lorem.paragraphs,
    calorie: Faker::Number.decimal(2, 3)
    conditions = []
    7.times do |i|
      condition = ([*ConditionDetail.first.id..ConditionDetail.last.id] - conditions).sample
      conditions.push condition
      food.food_conditions.create condition_detail_id: condition, is_match: ((i+n) % 2 == 0)
    end
end
