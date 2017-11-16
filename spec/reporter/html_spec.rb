# frozen_string_literal: true

require 'spec_helper'
require 'deep_cover/reporter/html'

module DeepCover
  module Reporter
    RSpec.describe HTML::Index do
      after { DeepCover.reset }

      let(:coverage) do
        DeepCover.cover(paths: 'spec') { require_relative '../cli_fixtures/trivial_gem/lib/trivial_gem' }
        DeepCover.coverage
      end

      let(:index) { HTML::Index.new(coverage.analysis.stats) }
      it {
        index.stats_to_data.should ==
          [{text: 'cli_fixtures/trivial_gem/lib',
            data:         {per_char_executed: 109,
                           per_char_not_executed: 8,
                           per_char_not_executable: 51,
                           per_char_ignored: 0,
                           branch_executed: 0,
                           branch_not_executed: 0,
                           branch_not_executable: 0,
                           branch_ignored: 0,
                           node_executed: 13,
                           node_not_executed: 2,
                           node_not_executable: 0,
                           node_ignored: 2,
                          },
            children:         [{text: 'cli_fixtures/trivial_gem/lib/trivial_gem.rb',
                                data:            {per_char_executed: 78,
                                                  per_char_not_executed: 8,
                                                  per_char_not_executable: 40,
                                                  per_char_ignored: 0,
                                                  branch_executed: 0,
                                                  branch_not_executed: 0,
                                                  branch_not_executable: 0,
                                                  branch_ignored: 0,
                                                  node_executed: 9,
                                                  node_not_executed: 2,
                                                  node_not_executable: 0,
                                                  node_ignored: 2,
                                                  },
                                },
                               {text: 'cli_fixtures/trivial_gem/lib/trivial_gem/version.rb',
                                data:            {per_char_executed: 31,
                                                  per_char_not_executed: 0,
                                                  per_char_not_executable: 11,
                                                  per_char_ignored: 0,
                                                  branch_executed: 0,
                                                  branch_not_executed: 0,
                                                  branch_not_executable: 0,
                                                  branch_ignored: 0,
                                                  node_executed: 4,
                                                  node_not_executed: 0,
                                                  node_not_executable: 0,
                                                  node_ignored: 0,
                                                 },
                               },
                              ],
            },
          ]
      }
    end

    RSpec.describe HTML::Tree do
      include HTML::Tree
      it { path_to_partial_paths('a/b/c').should == %w[a a/b a/b/c] }
      it { list_to_twig(%i[a b c]).should == {a: {b: {c: {}}}} }
      it {
        deep_merge([{a: {b: {c: {}}}},
                    {a: {b: {d: {}}}},
                   ]).should ==
          {a: {b: {c: {}, d: {}}}}
      }
      it {
        simplify(a: {b: {c: {}, d: {}}}).should ==
          {b: {c: {}, d: {}}}
      }

      let(:paths) { %w[abcd xyz abcef abceg abch].map { |s| s.split('').join('/') } }
      it {
        paths_to_tree(paths).should == {
                                         'a/b/c' => {'a/b/c/d' => {}, 'a/b/c/e' => {'a/b/c/e/f' => {}, 'a/b/c/e/g' => {}}, 'a/b/c/h' => {}},
                                         'x/y/z' => {},
                                       }
      }
    end
  end
end
