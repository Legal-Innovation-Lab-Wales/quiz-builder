# spec/factories/questions.rb
FactoryBot.define do
  factory :question do
    scenario { Scenario.first || association(:scenario) }
    user { scenario.user || association(:user) }
    sequence(:order)
    text { 'MyString' }
    description { 'MyString' }

    factory :question_with_answers do
      transient do
        answers_count { 4 }
      end

      after(:create) do |question, evaluator|
        evaluator.answers_count.times { question.answers << FactoryBot.create(:answer, question: question) }

        question.reload
      end
    end
  end
end
