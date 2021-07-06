# spec/requests/answers/create_spec.rb
require 'rails_helper'

RSpec.describe 'update answer (PUT answer)', type: :request do
  let(:admin) { create(:user, :admin) }
  let(:scenario) { create(:scenario) }
  let(:scenario_id) { scenario.id }
  let(:questions) { create_list(:question, 5, scenario: scenario) }
  let(:question) { questions.first }
  let(:question_id) { question.id }
  let(:answer) { create(:answer, :with_next_question_order) }
  let(:answer_id) { answer.id }

  let(:headers) { { 'ACCEPT' => 'application/json' } }

  context 'when admin signed in' do
    before { sign_in admin }

    let(:updated_attributes) { { answer: { text: 'updated text',
                                           variable_mods: { 'health' => 69, 'stamina' => 10,
                                                            'experience' => 10, 'coin' => 10 } } } }
    before { put "/scenarios/#{scenario_id}/questions/#{question_id}/answers/#{answer_id}",
                 params: updated_attributes, headers: headers }

    context 'when answer exists' do
      let(:updated_answer) { Answer.find(answer_id) }

      it 'returns status code 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'updates the answer text' do
        expect(updated_answer.text).to eq('updated text')
      end

      it 'updates the variable_mods' do
        expect(json['variable_mods']['health']).to eq('69')
        expect(updated_answer.variable_mods['health']).to eq('69')
      end

      it 'doesnt update other variable_mods' do
        expect(json['variable_mods']['coin']).to eq('10')
        expect(updated_answer.variable_mods['coin']).to eq('10')
      end

      context 'when updating the next question order' do
        let(:answer_original_next_question_id) { answer.next_question_id }
        let(:updated_attributes) { { answer: { next_question_order: questions.last.order } } }
        before { put scenario_question_answer_url(scenario, question, answer), params: updated_attributes, headers: headers }

        it 'should change the next question ID' do
          expect(Answer.find(answer_id).next_question_id).to eq(questions.last.id)
          expect(Answer.find(answer_id).next_question_id).not_to eq(answer_original_next_question_id)
        end

      end
    end

    context 'when the answer does not exist' do
      let(:answer_id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Answer/)
      end
    end
  end
end
