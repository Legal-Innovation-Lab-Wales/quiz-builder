# spec/requests/questions/delete_spec.rb
require 'rails_helper'

RSpec.describe 'delete question (DELETE questions)', type: :request do
  let(:admin) { create(:user, :admin) }
  let(:scenarios) { create_list(:scenario, 2) }
  let(:scenario_id) { scenarios.first.id }
  let!(:questions) { create_list(:question, 10, scenario: scenarios.first) }
  let(:question_id) { questions.first.id }

  let(:headers) { { 'ACCEPT' => 'application/json' } }

  context 'when admin signed in' do
    before { sign_in admin }
    before { delete "/scenarios/#{scenario_id}/questions/#{question_id}", headers: headers }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end

    it 'deletes the record' do
      expect { Question.find(question_id) }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
