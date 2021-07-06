# spec/models/organisation_spec.rb
require 'rails_helper'

RSpec.describe Organisation, type: :model do
  it { should have_many(:users) }
  it { should have_many(:scenarios).through(:users) }

  context 'model function' do
    let!(:admins) { create_list(:user, 2, :admin) }
    let!(:users) { create_list(:user, 3) }
    let!(:unapproved_users) { create_list(:user, 4, :unapproved) }
    let!(:organisation) { create(:organisation, users: admins + users + unapproved_users) }

    context 'admins' do
      it 'returns the organisations admins' do
        expect(organisation.admins).to eq(admins)
      end
    end

    context 'unapproved_users' do
      it 'returns the organisations unapproved users' do
        expect(organisation.unapproved_users).to eq(unapproved_users)
      end
    end
  end
end
