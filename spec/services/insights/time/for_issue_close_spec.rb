# frozen_string_literal: true

describe Insights::Time::ForIssueClose, type: :service do
  subject(:service_call) { described_class.new.call(insightable: repository, issues_ids: issues_ids) }

  let!(:first_monday) {
    date = DateTime.now.beginning_of_month + 7.days
    date -= 1.day until date.wday == 1
    DateTime.new(date.year, date.month, date.day)
  }
  let!(:repository) { create :repository }
  let!(:issue1) {
    create :issue,
           repository: repository,
           opened_at: first_monday + 1.day + 12.hours
  }
  let!(:issue2) {
    create :issue,
           repository: repository,
           opened_at: first_monday + 12.hours,
           closed_at: first_monday + 1.day + 13.hours
  }
  let(:issues_ids) { [issue1.id, issue2.id] }

  it 'returns list of times', :aggregate_failures do
    expect(service_call[:result]).to eq([90_000])
    expect(service_call[:errors]).to be_blank
  end
end
