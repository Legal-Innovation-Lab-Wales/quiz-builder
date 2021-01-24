# spec/requests/answers_request_spec.rb
require 'rails_helper'

RSpec.describe 'Answers', type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:quiz) { create(:quiz) }
  let(:quiz_id) { quiz.id }
  let(:question) { create(:question, quiz: quiz) }
  let(:question_id) { question.id }
  let(:answer) { create(:answer, question: question) }
  let(:answer_id) { answer.id }

  let(:headers) { { 'ACCEPT' => 'application/json' } }

  let(:valid_attributes) do
    { answer: { text: 'answering the question this way',
                variable_mods: [{ 'health': 10 }, { 'stamina': 10 }, { 'experience': 10 }, { 'coin': 10 }],
                next_question_order: question.order } }
  end

  describe 'create answer (POST quiz_question_answers)' do
    context 'when no user signed in' do
      before { post "/quizzes/#{quiz_id}/questions/#{question_id}/answers", params: valid_attributes, headers: headers }

      it 'returns status code 403' do
        expect(response).to have_http_status(401)
      end

      it 'returns an unauthorised message' do
        expect(response.body).to include('You need to sign in or sign up before continuing.')
      end
    end
    context 'when user signed in but not admin' do
      before { sign_in user }
      before { post "/quizzes/#{quiz_id}/questions/#{question_id}/answers", params: valid_attributes, headers: headers }

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'does not create a answer' do
        expect(Question.last.text).to_not eq('unauthorized user')
      end
    end
    context 'when admin signed in' do
      before { sign_in admin }
      context 'when the request is valid' do
        before { post "/quizzes/#{quiz_id}/questions/#{question_id}/answers", params: valid_attributes, headers: headers }

        it 'creates a answer' do
          expect(json['text']).to eq('answering the question this way')
        end

        it 'has the correct question id' do
          expect(Answer.last.question_id).to eq(question_id)
        end

        it 'returns status code 201' do
          expect(response).to have_http_status(201)
        end
      end
      context 'when no body in request' do
        before { post "/quizzes/#{quiz_id}/questions/#{question_id}/answers", params: {}, headers: headers }

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a failure message' do
          expect(response.body).to include('param is missing')
        end
      end
      context 'when record is missing an attribute ' do
        let(:invalid_attributes) { { answer: { next_question_order: Question.first.order } } }

        before { post "/quizzes/#{quiz_id}/questions/#{question_id}/answers", params: invalid_attributes, headers: headers }

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a failure message' do
          expect(response.body).to include('Validation failed:')
        end
      end
      context 'when an incorrect next_question_order is submitted' do
        let(:invalid_attributes) { { answer: { text: 'updated text', next_question_order: (Question.first.order + 5) } } }

        before { post "/quizzes/#{quiz_id}/questions/#{question_id}/answers", params: invalid_attributes, headers: headers }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end

        it 'returns a failure message' do
          expect(response.body).to include('Couldn\'t find Question')
        end
      end
    end
  end

  describe 'update answer (PUT quiz_question_answer)' do

    context 'when admin signed in' do
      before { sign_in admin }

      let(:updated_attributes) { { answer: { text: 'updated text' } } }
      # before { puts("question_id: #{question_id}. Quiz questions #{Quiz.find(quiz_id).questions.map {|q| [q.id, q.order]}}")}
      before { put "/quizzes/#{quiz_id}/questions/#{question_id}/answers/#{answer_id}", params: updated_attributes, headers: headers }

      context 'when answer exists' do
        it 'returns status code 204' do
          expect(response).to have_http_status(204)
        end

        it 'updates the answer' do
          updated_answer = Answer.find(answer_id)
          expect(updated_answer.text).to match(/updated text/)
        end
      end

      context 'when the answer does not exist' do
        let(:answer_id) { 0 }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end

        it 'returns a not found message' do
          expect(response.body).to match(/Couldn't find Answer/)
        end
      end
    end
  end

  describe 'delete answer (DELETE quiz_question_answer' do
    context 'when admin signed in' do
      before { sign_in admin }
      before { delete "/quizzes/#{quiz_id}/questions/#{question_id}/answers/#{answer_id}" }

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end

      it 'deletes the record' do
        expect { Answer.find(answer_id) }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
