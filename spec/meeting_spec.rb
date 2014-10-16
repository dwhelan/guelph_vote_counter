require_relative 'spec_helper'

describe Meeting do

  subject { Meeting.from_minutes file }

  describe 'Meeting: August 25, 2014' do
    let(:file) { 'spec/data/council_minutes_082514.pdf' }

    its(:date) { should eq Date.new 2014, 8, 25 }
  end
end


