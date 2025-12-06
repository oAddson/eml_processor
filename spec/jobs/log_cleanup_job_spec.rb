require 'rails_helper'

RSpec.describe LogCleanupJob, type: :job do
    it 'queues the job into the default queue' do
    expect(described_class.queue_name).to eq('low_priority')
  end
end
