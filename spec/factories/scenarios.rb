# spec/factories/scenarios.rb
FactoryBot.define do
  factory :scenario do
    user { create(:user, :admin) }
    name { 'Scenario Factory Name' }
    description { 'MyText' }
    variables { ['health', 'stamina', 'experience', 'coin'] }
    variable_initial_values { [100, 100, 0, 10] }
    variables_with_initial_values { { health: 100, stamina: 100, experience: 0, coin: 10 } }
    available { true }
  end

  trait :unavailable do
    available { false }
    user { User.first || association(:user) }
  end
end
