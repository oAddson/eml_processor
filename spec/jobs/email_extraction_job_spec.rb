require 'rails_helper'

RSpec.describe EmailExtractionJob, type: :job do
  it 'queues the job into the default queue' do
    expect(described_class.queue_name).to eq('default')
  end
end
