require_relative 'spec_helper'

describe Motion do

  subject { Motion.new text }

  [nil, '', '\t\n'].each do |empty_text|
    describe "with empty text: '#{empty_text || 'nil'}': " do
      let(:text) { empty_text }
      %w(preamble moved_by seconded_by text notes result).each do |part|
        its(part) { should eq '' }
      end

      %w(in_favour against).each do |part|
        its(part) { should eq [] }
      end
    end
  end

  describe 'simple motion' do
    let(:text) { <<-MOTION
    Confirmation of Minutes
      1. Moved by Councillor Van Hellemond
         Seconded by Councillor Dennis Larkin
      1. That the minutes of the Council Meetings held on June 18 and August 5, 2014 and the minutes of the Closed Meetings of Council held July 28 and August 5, 2014 be confirmed as recorded.
      2. That the minutes of the Council Meeting held on July 28, 2014 be amended to reflect Councillors Laidlaw and Burcher moving and seconding motion to adopt the minutes.
      VOTING IN FAVOUR: Mayor Farbridge, Councillors Bell, Dennis, Findlay, Furfaro, Guthrie, Hofland, Kovach, Laidlaw, Piper, Van Hellemond and Wettstein (12)
      VOTING AGAINST: (0)
      CARRIED
      MOTION
    }

    its(:preamble)    { should eq 'Confirmation of Minutes' }
    its(:moved_by)    { should eq 'Van Hellemond' }
    its(:seconded_by) { should eq 'Dennis Larkin' }
    its(:text)        { should match /\A1. That the minutes.*adopt the minutes\.\z/m }
    its(:in_favour)   { should eq ['Farbridge', 'Bell', 'Dennis', 'Findlay', 'Furfaro', 'Guthrie', 'Hofland', 'Kovach', 'Laidlaw', 'Piper', 'Van Hellemond', 'Wettstein'] }
    its(:against)     { should eq [] }
    its(:notes)       { should eq '' }
    its(:result)      { should eq 'CARRIED' }
    its(:unanimous?)  { should be_true }
  end
end


