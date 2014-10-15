require_relative '../lib/guelph_vote_counter'

RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true
end

describe Meeting do

  subject { Meeting.new file }

  context 'Meeting: August 25, 2014' do
    let(:file) { './data/council_minutes_082514.pdf' }

    its(:date) { should eq Date.new 2014, 8, 25 }
  end
end

