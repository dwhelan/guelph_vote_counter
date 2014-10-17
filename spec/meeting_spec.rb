require_relative 'spec_helper'

describe Meeting do

  describe 'from' do
    subject { Meeting.from_url "spec/data/#{file}" }

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

  describe 'with empty meeting minutes' do
    let(:text) { '' }
    its(:motions) { should eq [] }
  end

  describe 'ignore text up to "Call to Order""' do
    let(:text) { "blah blah CaLl TO order blah blah\nPreamble Moved by ... CARRIED" }
    it { expect(subject.motions[0].preamble).to eq 'Preamble' }
  end

  %w(CARRIED DEFEATED Deferral).each do |result|
    describe "Call to Order\nwith one motion that was #{result}" do
      let(:text) { "Moved by ... #{result}" }
      its('motions.count') { should eq 1 }
    end
  end

  describe 'remove headers' do
    let(:text)   { "foo#{header}bar foo#{header}bar" }
    let(:header) { "\n\t August 25, 2014 Guelph City Council Meeting\n\t" }
    its(:text)   { should eq 'foo bar foo bar' }
  end

  describe 'remove footers' do
    let(:text)   { "foo#{footer}bar foo#{footer}bar" }
    let(:footer) { "\n\t Page 1\n\t" }
    its(:text) { should eq 'foo bar foo bar' }
  end
end
