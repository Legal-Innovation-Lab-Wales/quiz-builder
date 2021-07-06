# spec/requests/questions/index_spec.rb
require 'rails_helper'

RSpec.describe 'index questions (GET questions)', type: :request do
  let(:admin) { create(:user, :admin) }
  let(:scenarios) { create_list(:scenario, 2) }
  let(:scenario_id) { scenarios.first.id }
  let!(:questions) { create_list(:question, 10, scenario: scenarios.first) }
  let!(:answers) { create_list(:answer, 10, question: questions.first) }

  let(:headers) { { 'ACCEPT' => 'application/json' } }

  context 'when user not signed in' do
    before { get "/scenarios/#{scenario_id}/questions", headers: headers }

    it 'returns status code 401 Unauthorized' do
      expect(response).to have_http_status(401)
    end

    it 'returns an unauthorised message' do
      expect(response.body).to include('You need to sign in or sign up before continuing.')
    end
  end

  context 'when any user signed in' do
    before { sign_in admin }
    before { get "/scenarios/#{scenario_id}/questions", headers: headers }

    it 'returns http status success' do
      expect(response).to have_http_status(:success)
      expect(response).to be_successful
    end

    it 'returns json content' do
      expect(response.content_type).to include('application/json')
    end

    it 'returns questions' do
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'includes answers with the questions' do
      expect(json.first['answers']).not_to be_empty
      expect(json.first['answers'].size).to eq(10)
    end

    it 'expects questions to be for the right scenario' do
      questions = JSON.parse(response.body)
      question_scenario_ids = questions.map { |q| q['scenario_id'] }
      expect(question_scenario_ids.uniq).to eq([scenario_id])
    end

    context 'when scenario does not exist' do
      let(:scenario_id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to include("Couldn't find Scenario")
      end
    end
  end
end
