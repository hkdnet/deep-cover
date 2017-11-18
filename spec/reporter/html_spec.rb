# frozen_string_literal: true

require 'spec_helper'
require 'deep_cover/reporter/html'

module DeepCover
  module Reporter
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
