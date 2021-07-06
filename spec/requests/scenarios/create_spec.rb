# spec/requests/scenarios/create_spec.rb
require 'rails_helper'

RSpec.describe 'create scenario (POST scenarios)', type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:alt_admin) { create(:user, :alt_admin) }

  let(:headers) { { 'ACCEPT' => 'application/json' } }

  let(:valid_attributes) do
    { scenario: { name: 'valid scenario name',
                  description: 'scenario description',
                  variables: %w[health stamina experience coin],
                  variable_initial_values: [100, 100, 0, 10],
                  available: true } }
  end

  context 'when user not signed in' do
    before { post '/scenarios', params: valid_attributes, headers: headers }

    it 'returns status code 401 Unauthorized' do
      expect(response).to have_http_status(401)
    end

    it 'returns an unauthorised message' do
      expect(response.body).to include('You need to sign in or sign up before continuing.')
    end
  end

  context 'when user signed in but not admin' do
    before { sign_in user }
    before { post '/scenarios', params: valid_attributes, headers: headers }

    it 'returns status code 403 Forbidden' do
      expect(response).to have_http_status(403)
    end

    it 'does not create a scenario' do
      expect(Scenario.all.count).to eq(0)
    end
  end

  context 'when admin signed in' do
    before { sign_in admin }
    context 'when the request is valid' do
      before { post '/scenarios', params: valid_attributes, headers: headers }

      it 'creates a question' do
        expect(json['name']).to eq('valid scenario name')
        expect(json['variables'][0]).to eq('health')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request in invalid' do
      before { post '/scenarios', params: { scenario: { name: 'Foo' } }, headers: headers }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a failure message' do
        expect(response.body).to include("Description can't be blank")
      end
    end

    context 'when no body in request' do
      before { post '/scenarios', params: {}, headers: headers }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a failure message' do
        expect(response.body).to include('param is missing')
      end
    end
  end
end
