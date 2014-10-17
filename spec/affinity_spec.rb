require_relative 'spec_helper'

describe Affinity do

  describe 'with no data' do
    its(:force_field) { should eq({nodes: [], links: []}) }
  end

  describe 'with a single pair' do
    before { subject.add %w(a b) }
    its(:force_field) { should eq( {
                                     nodes: [
                                              { name: 'a', group: 1 },
                                              { name: 'b', group: 1 },
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
                                              { name: 'a', group: 1 },
                                              { name: 'b', group: 1 },
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
                                              { name: 'a', group: 1 },
                                              { name: 'b', group: 1 },
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
                                              { name: 'a', group: 1 },
                                              { name: 'b', group: 1 },
                                              { name: 'c', group: 1 },
                                            ],
                                     links: [
                                              { source: 0, target: 1, value: 1 },
                                              { source: 0, target: 2, value: 1 },
                                              { source: 1, target: 2, value: 1 },
                                            ]
                                   }) }
  end
end
