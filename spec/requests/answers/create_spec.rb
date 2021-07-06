# spec/requests/answers/create_spec.rb
require 'rails_helper'

RSpec.describe 'create answer (POST answers)', type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:scenario) { create(:scenario) }
  let(:questions) { create_list(:question, 5, scenario: scenario) }
  let(:question) { questions.first }
  let(:question_id) { question.id }

  let(:headers) { { 'ACCEPT' => 'application/json' } }

  let(:valid_attributes) do
    { answer: { text: 'answering the question this way',
                variable_mods: { 'health' => 10, 'stamina' => 10, 'experience' => 10, 'coin' => 10 },
                next_question_order: questions.second.order } }
  end

  context 'when no user signed in' do
    before { post scenario_question_answers_url(scenario, question), params: valid_attributes, headers: headers }

    it 'returns status code 401 Unauthorized' do
      expect(response).to have_http_status(401)
    end

    it 'returns an unauthorised message' do
      expect(response.body).to include('You need to sign in or sign up before continuing.')
    end
  end

  context 'when user signed in but not admin' do
    before { sign_in user }
    before { post scenario_question_answers_url(scenario, question), params: valid_attributes, headers: headers }

    it 'returns status code 403 Forbidden' do
      expect(response).to have_http_status(403)
    end

    it 'does not create a answer' do
      expect(Answer.count).to be(0)
    end
  end

  context 'when admin signed in' do
    before { sign_in admin }
    context 'when the request is valid' do
      before { post scenario_question_answers_url(scenario, question), params: valid_attributes, headers: headers }

      it 'creates a answer' do
        expect(json['text']).to eq('answering the question this way')
      end

      it 'has the correct question id' do
        expect(Answer.last.question_id).to eq(question_id)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'has the valid variable mods' do
        expect(json['variable_mods']).to include('health')

      end

      context 'when not all variable_mods are passed' do
        let(:valid_attributes) do
          { answer: { text: 'answering the question this second way',
                      variable_mods: { 'health' => 10, 'stamina' => 10 },
                      next_question_order: questions.second.order } }
        end

        it 'creates a answer' do
          expect(json['text']).to eq('answering the question this second way')
        end

        it 'has valid variable mods' do
          expect(json['variable_mods']).to include('health', 'stamina')
          expect(json['variable_mods']).not_to include('coin')
        end

        it 'returns status code 201' do
          expect(response).to have_http_status(201)
        end

        context 'when no variable_mods are passed' do
          let(:valid_attributes) do
            { answer: { text: 'answering the question this third way',
                        next_question_order: questions.second.order } }
          end

          it 'creates a answer' do
            expect(json['text']).to eq('answering the question this third way')
          end

          it 'has no variable mods' do
            expect(json['variable_mods']).to be_nil
          end

          it 'returns status code 201' do
            expect(response).to have_http_status(201)
          end
        end
      end
    end

    context 'when no body in request' do
      before { post scenario_question_answers_url(scenario, question), params: {}, headers: headers }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a failure message' do
        expect(response.body).to include('param is missing')
      end
    end

    context 'when record is missing an attribute ' do
      let(:invalid_attributes) { { answer: { next_question_order: Question.first.order } } }

      before { post scenario_question_answers_url(scenario, question), params: invalid_attributes, headers: headers }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a failure message' do
        expect(response.body).to include('Validation failed:')
      end
    end

    context 'when an incorrect next_question_order is submitted' do
      let(:invalid_attributes) { { answer: { text: 'updated text', next_question_order: (Question.last.order + 5) } } }

      before { post scenario_question_answers_url(scenario, question), params: invalid_attributes, headers: headers }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a failure message' do
        expect(response.body).to include('Couldn\'t find Question')
      end
    end

    context 'when invalid variable_mods are submitted' do
      let(:invalid_attributes) do
        { answer: { text: 'this is a bad question',
                    variable_mods: { 'health' => 10, 'stamina' => 10, 'bad' => 10 },
                    next_question_order: questions.second.order } }
      end
      before { post scenario_question_answers_url(scenario, question), params: invalid_attributes, headers: headers }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a failure message' do
        expect(response.body).to include('Validation failed:')
        expect(response.body).to include('bad')
      end

    end
  end
end
