# frozen_string_literal: true

describe AccessTokens::CreateForm, type: :service do
  subject(:form) { instance.call(tokenable: tokenable, params: params) }

  let!(:instance) { described_class.new }
  let!(:company) { create :company }
  let!(:repository) { create :repository, company: company, provider: Providerable::GITHUB }

  context 'for company' do
    let(:tokenable) { company }

    context 'for invalid params' do
      let(:params) { { value: '' } }

      it 'does not create access token', :aggregate_failures do
        expect { form }.not_to change(AccessToken, :count)
        expect(form[:errors]).to eq ['Value must be filled']
      end
    end

    context 'for invalid format' do
      let(:params) { { value: 'glpat-*****-******' } }

      it 'does not create access token', :aggregate_failures do
        expect { form }.not_to change(AccessToken, :count)
        expect(form[:errors]).to eq ['Invalid PAT token format']
      end
    end

    context 'for valid params' do
      let(:params) { { value: 'github_pat_*****_******' } }

      it 'creates access token and succeeds', :aggregate_failures do
        form

        expect(AccessToken.where(tokenable: company).size).to eq 1
        expect(form[:errors]).to be_nil
      end

      context 'when access token already exist' do
        let!(:access_token) { create :access_token, tokenable: company }

        it 'replaces old token with new one', :aggregate_failures do
          form

          expect(AccessToken.where(tokenable: company).size).to eq 1
          expect(AccessToken.find_by(id: access_token.id)).to be_nil
          expect(form[:errors]).to be_nil
        end
      end

      context 'when company has repositories with different providers' do
        before { create :repository, company: company, provider: Providerable::GITLAB }

        it 'does not create access token and fails', :aggregate_failures do
          expect { form }.not_to change(AccessToken, :count)
          expect(form[:errors]).to eq ['Company has repositories of multiple providers']
        end
      end
    end
  end

  context 'for repository' do
    let(:tokenable) { repository }

    context 'for Github' do
      context 'for invalid params' do
        let(:params) { { value: '' } }

        it 'does not create access token and fails' do
          expect { form }.not_to change(AccessToken, :count)
        end
      end

      context 'for invalid format' do
        let(:params) { { value: 'some_random_key' } }

        it 'does not create access token and fails' do
          expect { form }.not_to change(AccessToken, :count)
        end
      end

      context 'for valid params' do
        let(:params) { { value: 'github_pat_*****_******' } }

        it 'creates access token and succeeds' do
          form

          expect(AccessToken.where(tokenable: repository).size).to eq 1
        end

        context 'when access token already exist' do
          let!(:access_token) { create :access_token, tokenable: repository }

          it 'replaces old token with new one', :aggregate_failures do
            form

            expect(AccessToken.where(tokenable: repository).size).to eq 1
            expect(AccessToken.find_by(id: access_token.id)).to be_nil
          end
        end
      end
    end

    context 'for Gitlab' do
      before { repository.update!(provider: Providerable::GITLAB) }

      context 'for invalid params' do
        let(:params) { { value: '' } }

        it 'does not create access token and fails' do
          expect { form }.not_to change(AccessToken, :count)
        end
      end

      context 'for invalid format' do
        let(:params) { { value: 'some_random_key' } }

        it 'does not create access token and fails' do
          expect { form }.not_to change(AccessToken, :count)
        end
      end

      context 'for valid params' do
        let(:params) { { value: 'glpat-***********' } }

        it 'creates access token and succeeds' do
          form

          expect(AccessToken.where(tokenable: repository).size).to eq 1
        end

        context 'when access token already exist' do
          let!(:access_token) { create :access_token, tokenable: repository }

          it 'replaces old token with new one', :aggregate_failures do
            form

            expect(AccessToken.where(tokenable: repository).size).to eq 1
            expect(AccessToken.find_by(id: access_token.id)).to be_nil
          end
        end
      end
    end
  end
end
