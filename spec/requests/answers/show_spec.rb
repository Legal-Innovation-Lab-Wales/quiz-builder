# spec/requests/scenarios/show_spec.rb
require 'rails_helper'

RSpec.describe 'show answer (GET answer)', type: :request do
  let(:admin) { create(:user, :admin) }
  let(:scenario) { create(:scenario) }
  let(:questions) { create_list(:question, 5, scenario: scenario) }
  let(:question) { questions.first }
  let(:question_id) { question.id }

  let(:headers) { { 'ACCEPT' => 'application/json' } }

  context 'when admin signed in' do
    before { sign_in admin }

    context 'and they begin a new answer' do
      before { get new_scenario_question_answer_url(scenario, question) }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'creates a new answer instance variable' do
        expect(assigns(:answer)).to be_present
        expect(assigns(:answer)).not_to be_persisted
      end
    end

    context 'and they edit an answer' do
      let!(:answer) { create(:answer, :with_next_question_order) }
      before { get edit_scenario_question_answer_path(scenario, question, answer) }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'sets the answer as an instance variable' do
        expect(assigns(:answer)).to eq(answer)
      end
    end
  end
end
