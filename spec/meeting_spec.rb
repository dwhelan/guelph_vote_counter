require_relative 'spec_helper'

describe Meeting do

  describe 'from' do
    subject { Meeting.from_minutes "spec/data/#{file}" }

    describe 'August 25, 2014' do
      let(:file) { 'council_minutes_082514.pdf' }

      its(:date) { should eq Date.new 2014, 8, 25 }
    end

    describe 'August 5, 2014' do
      let(:file) { 'council_minutes_0805141.pdf' }

      its(:date) { should eq Date.new 2014, 8, 5 }
      its('motions.count') { should eq 3 }
    end
  end

  subject { Meeting.new text }

  describe 'with empty meeting minues' do
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

