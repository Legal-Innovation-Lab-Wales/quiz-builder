# spec/requests/answers/create_spec.rb
require 'rails_helper'

RSpec.describe 'delete answer (DELETE answer)', type: :request do
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
    before { delete "/scenarios/#{scenario_id}/questions/#{question_id}/answers/#{answer_id}", headers: headers }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end

    it 'deletes the record' do
      expect { Answer.find(answer_id) }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
