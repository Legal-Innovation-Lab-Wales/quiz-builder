# spec/models/answer_spec.rb
require 'rails_helper'

RSpec.describe Answer, type: :model do
  # Association Test
  # ensure Answer record belongs to a single Question
  it { should belong_to(:question) }
  # ensure Answer record belongs to a single User
  it { should belong_to(:user) }

  # Validation Tests
  # ensure values are present before saving
  it { should validate_presence_of(:text) }
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:question_id) }

  context 'when creating an answer' do
    let(:answer) { create(:answer, :with_next_question_order) }

    it 'updates the next question id' do
      expect answer.next_question_id.present?
    end
  end

  context 'update variable mods' do
    let(:answer) { create(:answer) }

    it 'sets variable mods from scenario if missing with value 0' do
      expect(answer.variable_mods).to be_empty
      answer.update_variable_mods

      expect(answer.variable_mods).not_to be_empty

      answer.variable_mods.each_with_index do |variable_mod, index|
        expect(variable_mod[0]).to eq(answer.question.scenario.variables[index])
        expect(variable_mod[1]).to eq(0.to_s)
      end
    end

    it 'removes variable mods from answer if not present on scenario' do
      answer.variable_mods = { foo: 42 }

      answer.update_variable_mods
      expect(answer.variable_mods['foo']).not_to be_present
    end
  end
end
