# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  # rubocop: disable RSpec/HookArgument
  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
  # rubocop: enable RSpec/HookArgument
end
