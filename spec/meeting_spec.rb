require_relative 'spec_helper'

describe Meeting do


  describe 'Meeting: August 25, 2014' do
    subject { Meeting.from_minutes file }
    let(:file) { 'spec/data/council_minutes_082514.pdf' }

    its(:date) { should eq Date.new 2014, 8, 25 }
  end

  subject { Meeting.new text }

  describe '' do
    let(:text) { '' }
    its(:motions) { should eq [] }
  end

  %w(CARRIED DEFEATED Deferral).each do |result|
    describe "with one motion that was #{result}" do
      let(:text) { "Moved by ... #{result}" }
      its('motions.count') { should eq 1 }
    end
  end
end
