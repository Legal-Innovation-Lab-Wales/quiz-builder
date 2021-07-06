# spec/requests/questions/update_spec.rb
require 'rails_helper'

RSpec.describe 'update question (PUT questions)', type: :request do
  let(:admin) { create(:user, :admin) }
  let(:scenarios) { create_list(:scenario, 2) }
  let(:scenario_id) { scenarios.first.id }
  let!(:questions) { create_list(:question, 10, scenario: scenarios.first) }
  let(:question_id) { questions.first.id }

  let(:headers) { { 'ACCEPT' => 'application/json' } }

  context 'when admin signed in' do
    before { sign_in admin }
    let(:valid_attributes) { { question: { text: 'updated text' } } }
    before { put "/scenarios/#{scenario_id}/questions/#{question_id}", params: valid_attributes, headers: headers }

    context 'when question exists' do
      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end

      it 'updates the question' do
        updated_question = Question.find(question_id)
        expect(updated_question.text).to match(/updated text/)
      end
    end

    context 'when the question does not exist' do
      let(:question_id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Question/)
      end
    end
  end
end