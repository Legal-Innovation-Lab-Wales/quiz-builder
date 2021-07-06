# app/controllers/scenarios_controller.rb
class ScenariosController < ApplicationController
  before_action :set_scenario, only: %i[show update destroy]
  before_action :require_admin, only: %i[new create edit update delete]
  before_action :create_variables_hstore, only: %i[create update]

  # GET /scenarios
  def index
    @scenarios = set_scenarios

    respond_to do |format|
      format.html
      format.json { json_response(@scenarios) }
    end
  end

  # GET /scenarios/:id
  def show
    scenario = if current_user.admin?
                 @scenario.as_json(include: { questions: { include: :answers } })
               else
                 @scenario
               end
    @attempts = user_attempts
    respond_to do |format|
      format.html
      format.json { json_response(scenario) }
    end
  end

  # GET /scenarios/new
  def new
    @scenario = Scenario.new
  end

  # POST /scenarios
  def create
    if (@scenario = current_user.scenarios.create!(scenario_params.merge(variables_with_initial_values: create_variables_hstore)))
      respond_to do |format|
        format.html { redirect_to(@scenario) }
        format.json { json_response(@scenario, :created) }
      end
    end
  end

  # GET /scenarios/:id/edit
  def edit
    @scenario = Scenario.find(params[:id])
  end

  # PUT /scenarios/:id
  def update
    params = scenario_params.merge(variables_with_initial_values: create_variables_hstore) unless create_variables_hstore.nil?
    if @scenario.update!(params)
      respond_to do |format|
        format.html { redirect_to(@scenario) }
        format.json { json_response(@scenario, :no_content) }
      end
    end
  end

  # DELETE /scenarios/:scenario_id
  def destroy
    if @scenario.destroy
      respond_to do |format|
        format.html { redirect_to scenarios_path }
        format.json { json_response(@scenario, :no_content) }
      end
    end
  end

  private

  def set_scenarios
    if current_user.admin?
      current_user.organisation.scenarios
    else
      current_user.organisation.scenarios.available
    end
  end

  def set_scenario
    @scenario = if current_user.admin?
                  current_user.organisation.scenarios.find(params[:id])
                else
                  current_user.organisation.scenarios.available.find(params[:id])
                end
  end

  def user_attempts
    @scenario.attempts.where(user_id: current_user.id).order(:id)
  end

  def create_variables_hstore
    return unless params['scenario'].present?

    return unless params['scenario']['variables'].present? && params['scenario']['variable_initial_values'].present?

    vars = params['scenario']['variables']
    vals = params['scenario']['variable_initial_values']
    vars.zip(vals).to_h
  end

  def scenario_params
    # whitelist params
    params.require(:scenario).permit(:name, :description, :available, { variables: [] }, { variable_initial_values: [] }, variables_with_initial_values: {})
  end
end
