# frozen_string_literal: true

describe AddAccessTokenCommand do
  subject(:command) { instance.call(params.merge(tokenable: tokenable)) }

  let!(:instance) { described_class.new }
  let!(:company) { create :company }

  context 'for invalid tokenable' do
    let(:tokenable) { create :user }
    let(:params) { { value: 'glpa-*****-******' } }

    it 'does not create access token', :aggregate_failures do
      expect { command }.not_to change(AccessToken, :count)
      expect(command[:errors]).to eq ['Tokenable is not supported']
    end
  end

  context 'for company' do
    let(:tokenable) { company }

    context 'without repositories' do
      context 'for invalid format' do
        let(:params) { { value: 'glpa-*****-******' } }

        it 'does not create access token', :aggregate_failures do
          expect { command }.not_to change(AccessToken, :count)
          expect(command[:errors]).to eq ['Invalid PAT token format']
        end
      end

      context 'for valid params' do
        let(:params) { { value: 'github_pat_*****_******' } }

        it 'creates access token and succeeds', :aggregate_failures do
          expect { command }.to change(AccessToken.where(tokenable: company), :count).by(1)
          expect(command[:errors]).to be_nil
        end

        context 'with valid expired_at value' do
          let(:params) { { value: 'github_pat_*****_******', expired_at: '2024.11.01' } }

          it 'creates access token and succeeds', :aggregate_failures do
            expect { command }.to change(AccessToken.where(tokenable: company), :count).by(1)
            expect(command[:errors]).to be_nil
            expect(AccessToken.last.expired_at).to eq DateTime.new(2024, 11, 1)
          end
        end

        context 'with invalid expired_at value' do
          let(:params) { { value: 'github_pat_*****_******', expired_at: '' } }

          it 'creates access token and succeeds', :aggregate_failures do
            expect { command }.to change(AccessToken.where(tokenable: company), :count).by(1)
            expect(command[:errors]).to be_nil
            expect(AccessToken.last.expired_at).to be_nil
          end
        end
      end
    end

    context 'with repository' do
      before { create :repository, company: company, provider: Providerable::GITHUB }

      context 'for invalid params' do
        let(:params) { { value: '' } }

        it 'does not create access token', :aggregate_failures do
          expect { command }.not_to change(AccessToken, :count)
          expect(command[:errors]).to eq ['Value must be filled']
        end
      end

      context 'for invalid format' do
        let(:params) { { value: 'glpat-*****-******' } }

        it 'does not create access token', :aggregate_failures do
          expect { command }.not_to change(AccessToken, :count)
          expect(command[:errors]).to eq ['Invalid PAT token format']
        end
      end

      context 'for valid params' do
        let(:params) { { value: 'github_pat_*****_******' } }

        it 'creates access token and succeeds', :aggregate_failures do
          expect(command[:errors]).to be_nil
          expect(AccessToken.where(tokenable: company).size).to eq 1
        end

        context 'when access token already exist' do
          let!(:access_token) { create :access_token, tokenable: company }

          it 'replaces old token with new one', :aggregate_failures do
            expect(command[:errors]).to be_nil
            expect(AccessToken.where(tokenable: company).size).to eq 1
            expect(AccessToken.find_by(id: access_token.id)).to be_nil
          end
        end

        context 'when company has repositories with different providers' do
          before { create :repository, company: company, provider: Providerable::GITLAB }

          it 'does not create access token and fails', :aggregate_failures do
            expect { command }.not_to change(AccessToken, :count)
            expect(command[:errors]).to eq ['Company has repositories of multiple providers']
          end
        end
      end
    end
  end

  context 'for repository' do
    let!(:repository) { create :repository, company: company, provider: Providerable::GITHUB }
    let(:tokenable) { repository }

    context 'for Github' do
      context 'for invalid params' do
        let(:params) { { value: '' } }

        it 'does not create access token and fails' do
          expect { command }.not_to change(AccessToken, :count)
        end
      end

      context 'for invalid format' do
        let(:params) { { value: 'some_random_key' } }

        it 'does not create access token and fails' do
          expect { command }.not_to change(AccessToken, :count)
        end
      end

      context 'for valid params' do
        let(:params) { { value: 'github_pat_*****_******' } }

        it 'creates access token and succeeds' do
          command

          expect(AccessToken.where(tokenable: repository).size).to eq 1
        end

        context 'when access token already exist' do
          let!(:access_token) { create :access_token, tokenable: repository }

          it 'replaces old token with new one', :aggregate_failures do
            command

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
          expect { command }.not_to change(AccessToken, :count)
        end
      end

      context 'for invalid format' do
        let(:params) { { value: 'some_random_key' } }

        it 'does not create access token and fails' do
          expect { command }.not_to change(AccessToken, :count)
        end
      end

      context 'for valid params' do
        let(:params) { { value: 'glpat-***********' } }

        it 'creates access token and succeeds' do
          command

          expect(AccessToken.where(tokenable: repository).size).to eq 1
        end

        context 'when access token already exist' do
          let!(:access_token) { create :access_token, tokenable: repository }

          it 'replaces old token with new one', :aggregate_failures do
            command

            expect(AccessToken.where(tokenable: repository).size).to eq 1
            expect(AccessToken.find_by(id: access_token.id)).to be_nil
          end
        end
      end
    end
  end
end
