require 'rails_helper'

describe 'Smoke Tests - Production Health Checks', type: :request do
  describe 'Public Routes' do
    it 'GET / - Root (landing page) returns 200' do
      get '/'
      expect(response).to have_http_status(:ok)
    end

    it 'GET /welcome - Landing page returns 200' do
      get '/welcome'
      expect(response).to have_http_status(:ok)
    end

    it 'GET /users/sign_in - Sign in page returns 200' do
      get '/users/sign_in'
      expect(response).to have_http_status(:ok)
    end

    it 'GET /users/sign_up - Sign up page returns 200' do
      get '/users/sign_up'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'Error Handling' do
    it 'GET /nonexistent - Returns 404 for missing route' do
      get '/nonexistent-path-xyz'
      expect(response).to have_http_status(:not_found)
    end

    it 'GET /nonexistent/deeply/nested - Returns 404 for deep missing path' do
      get '/nonexistent/deeply/nested/path'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'Authentication Redirects' do
    it 'GET /dashboard - Redirects to sign_in when not authenticated' do
      get '/dashboard'
      expect(response).to redirect_to('/users/sign_in')
    end

    it 'GET /quests - Redirects to sign_in when not authenticated' do
      get '/quests'
      expect(response).to redirect_to('/users/sign_in')
    end
  end

  describe 'Database Connectivity' do
    it 'Database connection is active' do
      expect { ActiveRecord::Base.connection.execute('SELECT 1') }.not_to raise_error
    end

    it 'User table exists and is queryable' do
      expect { User.count }.not_to raise_error
    end
  end

  describe 'Rails Logger' do
    it 'Rails logger is configured and working' do
      expect { Rails.logger.info('Smoke test - logger functional') }.not_to raise_error
    end
  end
end
