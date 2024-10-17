# frozen_string_literal: true

# TODO: add tests for parallel request with creating similar entities
describe Import::Savers::PullRequests, type: :service do
  subject(:service_call) { described_class.new.call(repository: repository, data: data) }

  let!(:company) { create :company }
  let!(:repository) { create :repository, company: company }
  let(:data) {
    [
      {
        pull_number: 3,
        pull_created_at: nil,
        pull_closed_at: nil,
        pull_merged_at: nil,
        author: {
          external_id: '1',
          provider: Providerable::GITHUB,
          login: 'octocat',
          avatar_url: 'https://github.com/images/error/octocat_happy.gif',
          html_url: 'https://github.com/octocat'
        },
        reviewers: [
          {
            external_id: '1',
            provider: Providerable::GITHUB,
            login: 'octocat',
            avatar_url: 'https://github.com/images/error/octocat_happy.gif',
            html_url: 'https://github.com/octocat'
          },
          {
            external_id: '2',
            provider: Providerable::GITHUB,
            login: 'octocat2',
            avatar_url: 'https://github.com/images/error/octocat_happy.gif',
            html_url: 'https://github.com/octocat'
          }
        ],
        owner_avatar_url: 'https://github.com/images/error/octocat_happy.gif'
      },
      {
        pull_number: 2,
        pull_created_at: '2011-04-10T20:09:31Z',
        pull_closed_at: '2011-04-10T20:09:31Z',
        pull_merged_at: '2011-04-10T20:09:31Z',
        author: {
          external_id: '1',
          provider: Providerable::GITHUB,
          login: 'octocat',
          avatar_url: 'https://github.com/images/error/octocat_happy.gif',
          html_url: 'https://github.com/octocat'
        },
        reviewers: []
      },
      {
        pull_number: 12,
        pull_created_at: '2011-04-10T20:09:31Z',
        pull_closed_at: '2011-04-10T20:09:31Z',
        pull_merged_at: '2011-04-10T20:09:31Z',
        author: {
          external_id: '1',
          provider: Providerable::GITHUB,
          login: 'octocat',
          avatar_url: 'https://github.com/images/error/octocat_happy.gif',
          html_url: 'https://github.com/octocat'
        },
        reviewers: [],
        destination_branch_name: 'master'
      }
    ]
  }

  context 'when there are no pull requests' do
    context 'when there are excludes rules' do
      before do
        group = create :excludes_group, insightable: company
        create :excludes_rule,
               excludes_group: group,
               target: 'destination_branch_name',
               condition: 'equal',
               value: 'master'
      end

      it 'creates 2 new pull requests', :aggregate_failures do
        expect { service_call }.to(
          change(repository.pull_requests, :count).by(2)
            .and(change(Entity, :count).by(2))
            .and(change(PullRequest::Review, :count).by(2))
        )

        expect(repository.pull_requests.find_by(pull_number: 3).pull_created_at).to be_nil
        expect(repository.pull_requests.find_by(pull_number: 2).pull_created_at).not_to be_nil
        expect(repository.reload.owner_avatar_url).to eq 'https://github.com/images/error/octocat_happy.gif'
      end
    end

    context 'when there are no exclude rules' do
      it 'creates 3 new pull requests', :aggregate_failures do
        expect { service_call }.to(
          change(repository.pull_requests, :count).by(3)
            .and(change(Entity, :count).by(2))
            .and(change(PullRequest::Review, :count).by(2))
        )
      end
    end

    context 'for receiving PRs with changing state from draft to open for review' do
      let(:second_data) {
        [
          {
            pull_number: 3,
            pull_created_at: '2011-04-10T20:09:31Z',
            pull_closed_at: nil,
            pull_merged_at: nil,
            author: {
              external_id: 1,
              provider: Providerable::GITHUB,
              login: 'octocat',
              avatar_url: 'https://github.com/images/error/octocat_happy.gif',
              html_url: 'https://github.com/octocat'
            },
            reviewers: [
              {
                external_id: 1,
                provider: Providerable::GITHUB,
                login: 'octocat',
                avatar_url: 'https://github.com/images/error/octocat_happy.gif',
                html_url: 'https://github.com/octocat'
              },
              {
                external_id: 2,
                provider: Providerable::GITHUB,
                login: 'octocat2',
                avatar_url: 'https://github.com/images/error/octocat_happy.gif',
                html_url: 'https://github.com/octocat'
              }
            ]
          }
        ]
      }

      it 'sets pull_created_at to current time', :aggregate_failures do
        service_call

        pull_request = repository.pull_requests.find_by(pull_number: 3)
        expect(pull_request.pull_created_at).to be_nil

        described_class.new.call(repository: repository, data: second_data)

        expect(pull_request.reload.pull_created_at).not_to be_nil
        expect(pull_request.pull_created_at.to_date).not_to eq DateTime.new(2011, 4, 10, 20, 9, 31)
      end
    end

    context 'when there is existing entity' do
      let!(:entity) { create :entity, external_id: '1' }

      it 'creates just 1 new entity', :aggregate_failures do
        expect { service_call }.to(
          change(Entity, :count).by(1)
          .and(change(PullRequest::Review, :count).by(2))
        )

        expect(entity.reload.login).to eq 'octocat'
      end
    end

    context 'when data is empty' do
      let(:data) { [] }

      before { repository.update!(owner_avatar_url: 'avatar_url') }

      it 'does not update owner_avatar_url', :aggregate_failures do
        expect { service_call }.not_to change(repository.pull_requests, :count)
        expect(repository.reload.owner_avatar_url).to eq 'avatar_url'
      end
    end
  end

  context 'when there is 1 existing pull request' do
    let!(:pull_request) { create :pull_request, repository: repository, pull_number: 2 }

    before do
      group = create :excludes_group, insightable: company
      create :excludes_rule,
             excludes_group: group,
             target: 'destination_branch_name',
             condition: 'equal',
             value: 'master'
    end

    it 'creates 1 new pull request', :aggregate_failures do
      expect { service_call }.to(
        change(repository.pull_requests, :count).by(1)
          .and(change(Entity, :count).by(2))
          .and(change(PullRequest::Review, :count).by(2))
      )

      expect(pull_request.reload.open?).to be_falsy
    end

    context 'when there is 1 PR entity' do
      before { create :entity, external_id: '1' }

      it 'creates 1 new entity', :aggregate_failures do
        expect { service_call }.to(
          change(Entity, :count).by(1)
          .and(change(PullRequest::Review, :count).by(2))
        )
      end
    end
  end

  context 'when there is 1 old existing pull request' do
    let!(:pull_request) { create :pull_request, repository: repository, pull_number: 1 }

    before do
      group = create :excludes_group, insightable: company
      create :excludes_rule,
             excludes_group: group,
             target: 'destination_branch_name',
             condition: 'equal',
             value: 'master'
    end

    it 'creates 2 new pull requests' do
      expect { service_call }.to change { repository.pull_requests.pluck(:pull_number) }.from([1]).to([3, 2])
    end

    it 'destroys old pull request' do
      service_call

      expect(repository.pull_requests.find_by(pull_number: pull_request.pull_number)).to be_nil
    end

    it 'creates 2 new entities' do
      expect { service_call }.to change(Entity, :count).by(2)
    end
  end
end
