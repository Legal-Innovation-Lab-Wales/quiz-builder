# spec/requests/scenarios/show_spec.rb
require 'rails_helper'

RSpec.describe 'show scenario (GET scenario)', type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let!(:scenario) { create(:scenario, user: admin) }
  let(:scenario_id) { scenario.id }
  let!(:questions) { create_list(:question, 10, scenario: scenario) }

  let(:headers) { { 'ACCEPT' => 'application/json' } }

  context 'when user not signed in' do

    before { get "/scenarios/#{scenario_id}", headers: headers }

    it 'returns status code 401 Unauthorized' do
      expect(response).to have_http_status(401)
    end

    it 'returns an unauthorised message' do
      expect(response.body).to include('You need to sign in or sign up before continuing.')
    end
  end

  context 'when any user signed in' do
    before { sign_in user }
    before { get "/scenarios/#{scenario_id}", headers: headers }

    context 'when the record exits' do

      it 'returns the scenario' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(scenario_id)
      end

      it 'doesnt include questions with the scenario' do
        expect(json['questions']).to be_nil
      end

      it 'returns http status success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns json content' do
        expect(response.content_type).to include('application/json')
      end

      it 'expects the scenario to be available' do
        expect(json['available']).to be_truthy
      end

      it 'expects the scenario to be from the correct organisation' do
        expect(User.find(json['user_id']).organisation_id).to eq(user.organisation_id)
      end

    end

    context 'when the record does not exist' do
      let(:scenario_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to include('Couldn\'t find Scenario')
      end
    end

    context 'when the scenario is not available' do
      let(:unavailable_scenario) { create(:scenario, :unavailable) }

      before { get "/scenarios/#{unavailable_scenario.id}", headers: headers }

      it 'returns http status not found' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns json content' do
        expect(response.content_type).to include('application/json')
      end

      it 'does not return the scenario' do
        expect(Scenario.find(unavailable_scenario.id)).to be_present
        expect(response.body).to include('Couldn\'t find Scenario')
      end
    end
  end

  context 'when admin signed in' do
    before { sign_in admin }

    context 'and they begin a new scenario' do
      before { get '/scenarios/new' }

      it 'assigns new scenario instance variable' do
        expect(assigns(:scenario)).to be_present
        expect(assigns(:scenario)).not_to be_persisted
      end

      it 'returns a status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'and they edit a scenario' do
      let!(:scenario) { create(:scenario) }
      before { get "/scenarios/#{scenario.id}/edit" }

      it 'assigns scenario instance variable' do
        expect(assigns(:scenario)).to eq(scenario)
      end

      it 'returns a status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'and scenario is not available' do
      let(:unavailable_scenario) { create(:scenario, :unavailable) }
      let!(:questions) { create_list(:question, 10, scenario: unavailable_scenario) }
      before { get "/scenarios/#{unavailable_scenario.id}", headers: headers }

      it 'returns the scenario' do
        expect(Scenario.find(unavailable_scenario.id)).to be_present
        expect(json).not_to be_empty
        expect(json['id']).to eq(unavailable_scenario.id)
      end

      it 'includes questions with the scenario' do
        expect(json['questions']).not_to be_empty
        expect(json['questions'].size).to eq(10)
      end

      it 'returns http status success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns json content' do
        expect(response.content_type).to include('application/json')
      end

      it 'expects the scenario to be not available' do
        expect(json['available']).to be_falsey
      end
    end
  end
end