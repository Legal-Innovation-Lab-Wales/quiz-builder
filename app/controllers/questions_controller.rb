# app/controllers/questions_controller.rb
class QuestionsController < ApplicationController
  before_action :set_scenario
  before_action :set_question, except: %i[new create index]
  before_action :set_attempt, :verify_attempt, :verify_question, only: :show
  before_action :require_admin, except: :show

  # GET /scenarios/:scenario_id/questions
  def index
    @questions = Question.all.where(scenario_id: @scenario.id)
    respond_to do |format|
      format.html
      # TODO: Improve this query
      format.json { json_response(@questions.as_json(include: :answers)) }
    end
  end

  # GET /scenarios/:scenario_id/questions/:id
  def show
    respond_to do |format|
      format.html
      # TODO: Improve this query
      format.json { json_response(@question.as_json(include: :answers)) }
    end
  end

  # GET /scenarios/:scenario_id/questions/new
  def new
    @question = Question.new
    @question_orders = question_orders
  end

  # POST /scenarios/:scenario_id/questions
  def create
    if (@question = current_user.questions.create!(question_params.merge(scenario_id: @scenario.id)))
      respond_to do |format|
        format.html { redirect_to scenario_path(@question.scenario_id, anchor: "question_order_#{@question.order}") }
        format.json { json_response(@question.as_json, :created) }
      end
    end
  end

  # GET /scenarios/:scenario_id/questions/:id/edit
  def edit
    @question_orders = question_orders
  end

  # PUT /scenarios/:scenario_id/questions/:id
  def update
    if @question.update(question_params)
      respond_to do |format|
        format.html { redirect_to scenario_path(@question.scenario_id, anchor: "question_order_#{@question.order}") }
        format.json { json_response(@question, :no_content) }
      end
    end
  end

  # DELETE /scenarios/:scenario_id/questions/:id
  def destroy
    if @question.destroy
      respond_to do |format|
        format.html { redirect_to scenario_path(@question.scenario_id) }
        format.json { json_response(@question, :no_content) }
      end
    end
  end

  private

  def verify_attempt
    return unless @attempt.nil? || @attempt.completed

    redirect_to scenario_path(@scenario),
                notice: 'You need to start or resume a scenario to view its questions'
  end

  def verify_question
    return unless @question.id != @attempt.next_question_id && !@attempt.been_answered?(@question.id)

    redirect_to scenario_question_path(@scenario, @attempt.next_question_id),
                notice: 'This is the question you should be answering'
  end

  def set_scenario
    @scenario = if current_user.admin?
              current_user.organisation.scenarios.find(params[:scenario_id])
            else
              current_user.organisation.scenarios.available.find(params[:scenario_id])
            end
  end

  def set_question
    @question = @scenario.questions.find(params[:id])
  end

  def set_attempt
    @attempt = Attempt.where('user_id = ?', current_user.id).find(session["scenario_id_#{@scenario.id}_attempt_id"])
  rescue ActiveRecord::RecordNotFound
    redirect_to scenario_path(@scenario),
                notice: 'You need to start or resume a scenario to view its questions'
  end

  def question_params
    # whitelist params
    params.require(:question).permit(:order, :text, :description, :scenario_id)
  end

  def question_orders
    @scenario.questions.map(&:order)
  end
end
