require_relative 'spec_helper'

describe Affinity do

  subject { Meeting.new file }

  context 'Meeting: August 25, 2014' do
    let(:file) { './data/council_minutes_082514.pdf' }

    its(:date) { should eq Date.new 2014, 8, 25 }
  end
end
