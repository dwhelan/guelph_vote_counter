#encoding: UTF-8

require_relative 'spec_helper'

describe Motion do

  subject { Motion.new text }

  ['', '\t\n'].each do |empty_text|
    describe "with empty text: '#{empty_text}': " do
      let(:text) { empty_text }

      %w(preamble moved_by seconded_by text notes result).each do |part|
        its(part) { should eq '' }
      end

      %w(in_favour against).each do |part|
        its(part) { should eq [] }
      end
    end
  end

  describe 'typos' do
    describe 'with "Councilllors" instead of "Councillors"' do
      let(:text)      { "VOTING IN FAVOUR: Mayor Farbridge,, Councilllors Bell (2)" }
      its(:in_favour)   { should eq ['Farbridge', 'Bell'] }
    end

    describe 'with "Councilors" instead of "Councillors"' do
      let(:text)      { "VOTING IN FAVOUR: Mayor Farbridge,, Councilors Bell (2)" }
      its(:in_favour)   { should eq ['Farbridge', 'Bell'] }
    end

    describe 'with "Dennis Findlay"' do
      let(:text)      { "VOTING IN FAVOUR: Dennis Findlay (1)" }
      its(:in_favour)   { should eq ['Dennis', 'Findlay'] }
    end

    describe 'with "Piperand Van Hellemond"' do
      let(:text)      { "VOTING IN FAVOUR: Piperand Van Hellemond (1)" }
      its(:in_favour)   { should eq ['Piper', 'Van Hellemond'] }
    end
  end

  describe 'blank votes in_favour' do
    let(:text)      { "VOTING IN FAVOUR: Mayor Farbridge,, Councillors Bell (2)" }
    its(:in_favour) { should eq %w(Farbridge Bell) }
  end

  describe 'votes in_favour with extra commas and spaces' do
    let(:text)      { "VOTING IN FAVOUR: Mayor Farbridge,, , Councillors Bell (2)" }
    its(:in_favour) { should eq %w(Farbridge Bell) }
  end

  describe 'blank votes against' do
    let(:text)    { "VOTING AGAINST: Mayor Farbridge, Councillors Bell (2)" }
    its(:against) { should eq %w(Farbridge Bell) }
    it { expect(subject.voted_differently?('Farbridge', 'Bell')).to be_false }
  end

  describe 'when all in favour' do
    let(:text)      { "VOTING IN FAVOUR: Mayor Farbridge, Councillors Bell (2)\nVOTING AGAINST: (0)" }
    its(:in_favour) { should_not be_empty }
    its(:against)   { should be_empty }
    it { should_not be_contested }
    it { should be_unanimous }
    it { expect(subject.voted_differently?('Farbridge', 'Bell')).to be_false }
  end

  describe 'when all against' do
    let(:text)      { "VOTING IN FAVOUR: (0)\nVOTING AGAINST: Mayor Farbridge, Councillors Bell (2)" }
    its(:in_favour) { should be_empty }
    its(:against)   { should_not be_empty }
    it { should_not be_contested }
    it { should be_unanimous }
    it { expect(subject.voted_differently?('Farbridge', 'Bell')).to be_false }
  end

  describe 'when the vote is split' do
    let(:text)      { "VOTING IN FAVOUR: Mayor Farbridge (1)\nVOTING AGAINST: Councillors Bell (1)" }
    its(:in_favour) { should_not be_empty }
    its(:against)   { should_not be_empty }
    it { should be_contested }
    it { should_not be_unanimous }
    it { expect(subject.voted_differently?('Farbridge', 'Bell')).to be_true }
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
    its(:in_favour)   { should eq ['Farbridge', 'Bell', 'Dennis', 'Findlay', 'Furfaro', 'Guthrie', 'Hofland', 'Kovach', 'Laidlaw', 'Piper', 'Van Hellemond', 'Wettstein'] }
    its(:against)     { should eq [] }
    its(:notes)       { should eq '' }
    its(:result)      { should eq 'CARRIED' }
    its(:unanimous?)  { should be_true }
    its(:contested?)  { should be_false }
    its(:text)        { should match /\A1. That the minutes.*adopt the minutes\.\z/m }
  end

  describe 'deferred motion' do
    let(:text) { <<-MOTION
      PBEE-2014.27 Downtown Streetscape Manual, Built Form Standards and St. George’s Square Concept
      Mr. Todd Salter, General Manager of Planning Services, introduced the report.
      Mr. David DeGroot, Urban Designer, provided an overview of the Downtown Streetscape Manual, Built Form Standards and St. George’s Square Concept. He highlighted the collaborative engagement process undertaken with the various public stakeholders.
      Mr. Steve Baldamus was not present.
      Mr. Marty Williams was present on behalf of the Downtown Guelph Business Association, and thanked staff for the opportunities to comment on the document. He advised the Association is supportive of the overall plan but have not reached a conclusion of what St. George’s Square should look like. He suggested there is time to work out the details prior to the final proposal being presented to Council.
      8. Moved by Councillor Bell Seconded by Councillor Wettstein
      1. That the Planning, Building, Engineering and Environment Report 14-47, regarding the Downtown Guelph Downtown Streetscape Manual, Built Form Standards and St. George’s Square Concept, dated August 5, 2014, be received.
      2. That the Streetscape Manual (contained in Chapter 2 of Attachment 1) be adopted and that staff be directed to use the Streetscape Manual to guide the design of the
      City’s public realm capital projects and private investments that impact the public realm in the Downtown.
      3. That the Downtown Built Form Standards (contained in Chapter 3 of Attachment 1) be adopted and that staff be directed to use the document to guide the review of development applications within Downtown.
      4. That Council endorse the vision, principles and general design elements illustrated by the Conceptual Design for St. George’s Square (contained in Chapter 4 of Attachment 1)
      5. That, as individual public realm capital projects begin advancing through the detailed design phase prior to construction, such as St. George’s Square and other streetscape reconstruction projects, staff continue to engage the public and businesses in the design and construction planning process phase; and that staff keep council informed regarding refinements and improvements to the design made through the detailed design process.
      6. That the cost estimates for the Streetscape Manual and the Conceptual Design for St. George’s Square be referred to the 2015 operating and capital budget and 10 year capital budgeting process.
      Deferral
    MOTION
    }

    its(:preamble)    { should match /PBEE.*presented to Council\./m }
    its(:moved_by)    { should eq 'Bell' }
    its(:seconded_by) { should eq 'Wettstein' }
    its(:in_favour)   { should eq [] }
    its(:against)     { should eq [] }
    its(:notes)       { should eq '' }
    its(:result)      { should eq 'DEFERRED' }
    its(:unanimous?)  { should be_true }
    its(:contested?)  { should be_false }
    its(:text)        { should match /\A1\. That the Planning, Building, Engineering.*10 year capital budgeting process\.\z/m }
  end
end
