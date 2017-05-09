# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UsersController, type: :request do
  let(:steve) { create(:user, first_name: 'Steve')}
  let(:john) { create(:user, first_name: 'Jonh') }
  describe 'GET index' do

    context 'with authenticated user' do
      it 'returns accepted and created users' do
        # force lazy evaluation of let to build users
        newguy = User.invite!({:email=>'newguy@test.com'}, john)
        steve
        @auth_headers = john.create_new_auth_token
        get "/users.json", headers: @auth_headers
        expect(response.header['Content-Type']).to include('application/json')
        body = JSON.parse(response.body)
        expect(body[0]["id"]).to eq(john.id)
        expect(body[1]["id"]).to eq(steve.id)
        expect(body.length).to eq(2) #does not have newguy
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        get "/users.json"
        expect(response.status).to eq(401)
      end
    end
  end
end
