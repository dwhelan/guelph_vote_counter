require_relative 'spec_helper'

describe Affinity do

  describe 'with no data' do
    its(:force_field) { should eq({nodes: [], links: []}) }
  end

  describe 'with empty array' do
    before { subject.add [] }
    its(:force_field) { should eq({nodes: [], links: []}) }
  end

  describe 'with a single item' do
    before { subject.add %w(a) }
    its(:force_field) { should eq({nodes: [], links: []}) }
  end

  describe 'with a single pair' do
    before { subject.add %w(a b) }
    its(:force_field) { should eq( {
                                     nodes: [
                                              { name: 'a', group: 0 },
                                              { name: 'b', group: 0 },
                                            ],
                                     links: [
                                              { source: 0, target: 1, value: 1 },
                                            ]
                                   }) }
  end

  describe 'with a pair in reverse order' do
    before { subject.add %w(b a) }
    its(:force_field) { should eq( {
                                     nodes: [
                                              { name: 'a', group: 0 },
                                              { name: 'b', group: 0 },
                                            ],
                                     links: [
                                              { source: 0, target: 1, value: 1 },
                                            ]
                                   }) }
  end

  describe 'with two pairs' do
    before { subject.add %w(a b); subject.add %w(a b) }
    its(:force_field) { should eq( {
                                     nodes: [
                                              { name: 'a', group: 0 },
                                              { name: 'b', group: 0 },
                                            ],
                                     links: [
                                              { source: 0, target: 1, value: 2 },
                                            ]
                                   }) }
  end

  describe 'with three items' do
    before { subject.add %w(a b c) }
    its(:force_field) { should eq( {
                                     nodes: [
                                              { name: 'a', group: 0 },
                                              { name: 'b', group: 0 },
                                              { name: 'c', group: 0 },
                                            ],
                                     links: [
                                              { source: 0, target: 1, value: 1 },
                                              { source: 0, target: 2, value: 1 },
                                              { source: 1, target: 2, value: 1 },
                                            ]
                                   }) }
  end

  describe 'when selecting top items' do
    before { subject.add %w(a b c d) }
    before { subject.add %w(a b) }
    before { subject.add %w(a b) }
    before { subject.add %w(c d) }
    it { expect(subject.force_field(min: 2)).to eq(
                                                  nodes: [
                                                           { name: 'a', group: 0 },
                                                           { name: 'b', group: 0 },
                                                           { name: 'c', group: 0 },
                                                           { name: 'd', group: 0 },
                                                         ],
                                                  links: [
                                                           { source: 0, target: 1, value: 3 },
                                                           { source: 2, target: 3, value: 2 },
                                                         ]
                                                ) }
  end

  describe 'groups' do
    before { subject.add_group 'a' }
    before { subject.add %w(a b); subject.add %w(a b) }
    its(:force_field) { should eq( {
                                     nodes: [
                                              { name: 'a', group: 1 },
                                              { name: 'b', group: 0 },
                                            ],
                                     links: [
                                              { source: 0, target: 1, value: 2 },
                                            ]
                                   }) }

  end
end
