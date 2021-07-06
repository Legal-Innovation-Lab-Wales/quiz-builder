# spec/requests/questions/show_spec.rb
require 'rails_helper'

RSpec.describe 'show question (GET scenario_question)', type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:scenarios) { create_list(:scenario, 2) }
  let(:scenario_id) { scenarios.first.id }
  let!(:questions) { create_list(:question, 10, scenario: scenarios.first) }
  let(:question_id) { questions.first.id }

  let(:headers) { { 'ACCEPT' => 'application/json' } }

  context 'when user not signed in' do
    before { get "/scenarios/#{scenario_id}/questions/#{question_id}", headers: headers }

    it 'returns status code 401 Unauthorized' do
      expect(response).to have_http_status(401)
    end

    it 'returns an unauthorised message' do
      expect(response.body).to include('You need to sign in or sign up before continuing.')
    end
  end

  context 'when user signed in' do
    before {  get "/scenarios/#{scenario_id}/questions/#{question_id}", headers: headers }

    it 'sets the question instance variable including the answers' do

    end
  end

  context 'when admin signed in' do
    before { sign_in admin }

    context 'and they begin a new question' do
      before { get "/scenarios/#{scenario_id}/questions/new"}

      it 'assigns new question instance variable' do
        expect(assigns(:question)).to be_present
        expect(assigns(:question)).not_to be_persisted
      end

      it 'assigns the scenario instance variable' do
        expect(assigns(:scenario)).to eq(scenarios.first)
      end

      it 'assigns mapped array of questions ordered by their "order" column' do
        expect(assigns(:question_orders)).to eq(questions.map(&:order))
      end

      it 'returns a status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'and they edit a question' do
      before { get "/scenarios/#{scenario_id}/questions/#{question_id}/edit" }

      it 'assigns the scenario instance variable' do
        expect(assigns(:scenario)).to eq(scenarios.first)
      end

      it 'assigns the question instance variable' do
        expect(assigns(:question)).to eq(questions.first)
      end

      it 'assigns mapped array of questions ordered by their "order" column' do
        expect(assigns(:question_orders)).to eq(questions.map(&:order))
      end

      it 'returns a status code 200' do
        expect(response).to have_http_status(200)
      end
    end
  end
end