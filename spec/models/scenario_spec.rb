# spec/models/answer_spec.rb
require 'rails_helper'

RSpec.describe Scenario, type: :model do
  let!(:scenario) { create(:scenario_with_questions) }

  # Association Test
  # ensure Scenario record belongs to a single User
  it { should belong_to(:user) }
  # ensure Scenario model has a 1:m relationship with the Question model
  it { should have_many(:questions).dependent(:destroy) }
  # ensure Scenario model has a 1:m relationship with the Attempt model
  it { should have_many(:attempts) }
  # ensure scenario response to organisation
  it { should respond_to(:organisation) }

  # Validation Tests
  # ensure values are present before saving
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:variables) }
  it { should validate_presence_of(:variable_initial_values) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:description) }

  context 'model function' do
    context 'first_question' do
      it 'returns question with order 0' do
        expect(scenario.first_question.order).to eq(0)
      end
    end

    context 'update_answers' do
      it 'triggers update to all answers variable mods' do
        scenario.answers.each { |answer| expect(answer).to receive(:update_variable_mods) }
        scenario.send(:update_answers)
      end
    end
  end
end
