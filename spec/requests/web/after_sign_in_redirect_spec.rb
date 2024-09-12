# frozen_string_literal: true

describe 'After sign in redirect' do
  let!(:user_session) { create :user_session }

  before do
    allow(Authkeeper::Container.resolve('services.providers.github')).to(
      receive(:call).and_return(github_auth_result)
    )
  end

  context 'for invalid auth result' do
    let(:github_auth_result) do
      {
        result: {
          uid: '123',
          provider: 'gitlab',
          login: 'octocat',
          email: nil
        }
      }
    end

    it 'redirects to root page', :aggregate_failures do
      get '/repositories'

      expect(response).to redirect_to root_path
      follow_redirect!

      get '/auth/github/callback?code=123456'

      expect(response).to redirect_to root_path
      follow_redirect!

      expect(response.body).to include('Get the PR statistics you always needed')
    end
  end

  context 'for valid auth result' do
    let(:github_auth_result) do
      {
        result: {
          uid: '123',
          provider: 'gitlab',
          login: 'octocat',
          email: user_session.user.email
        }
      }
    end

    it 'redirects to previous visited page after sign in', :aggregate_failures do
      get '/repositories'

      expect(response).to redirect_to root_path
      follow_redirect!

      get '/auth/github/callback?code=123456'

      follow_redirect!

      expect(response.body).to include('Repositories')
    end
  end
end
