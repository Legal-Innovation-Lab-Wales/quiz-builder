# spec/requests/questions/create_spec.rb
require 'rails_helper'

RSpec.describe 'create question (POST questions)', type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:scenarios) { create_list(:scenario, 2) }
  let(:scenario_id) { scenarios.first.id }
  let!(:questions) { create_list(:question, 10, scenario: scenarios.first) }

  let(:headers) { { 'ACCEPT' => 'application/json' } }

  let(:valid_attributes) do
    { question: { order: (Question.last.order + 1),
                  description: 'Setting the scene',
                  text: 'asking the question' } }
  end

  context 'when user not signed in' do
    before { post "/scenarios/#{scenario_id}/questions", params: valid_attributes, headers: headers }

    it 'returns status code 401 Unauthorized' do
      expect(response).to have_http_status(401)
    end

    it 'returns an unauthorised message' do
      expect(response.body).to include('You need to sign in or sign up before continuing.')
    end
  end

  context 'when user signed in but not admin' do
    before { sign_in user }
    before { post "/scenarios/#{scenario_id}/questions", params: valid_attributes, headers: headers }

    it 'returns status code 403 Forbidden' do
      expect(response).to have_http_status(403)
    end

    it 'does not create a question' do
      expect(Question.last.text).to_not eq('unauthorized user')
    end
  end

  context 'when admin signed in' do
    before { sign_in admin }

    context 'when the request is valid' do
      before { post "/scenarios/#{scenario_id}/questions", params: valid_attributes, headers: headers }

      it 'creates a question' do
        expect(json['text']).to eq('asking the question')
      end

      it 'has the correct scenario id' do
        expect(Question.last.scenario_id).to eq(scenario_id)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when no body in request' do
      before { post "/scenarios/#{scenario_id}/questions", params: {}, headers: headers }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a failure message' do
        expect(response.body).to include('param is missing')
      end
    end

    context 'when record is not unique' do
      let(:invalid_attributes) { { question: { order: Question.first.order } } }
      before { post "/scenarios/#{scenario_id}/questions", params: invalid_attributes, headers: headers }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a failure message' do
        expect(response.body).to include('unique')
      end
    end
  end
end