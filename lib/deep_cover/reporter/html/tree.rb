# frozen_string_literal: true

module DeepCover
  module Reporter
    # Utility functions to deal with trees
    module HTML::Tree
      def paths_to_tree(paths)
        twigs = paths.map do |path|
          partials = path_to_partial_paths(path)
          list_to_twig(partials)
        end
        tree = deep_merge(twigs)
        simplify(tree)
      end

      # 'some/example/path' => %w[some some/example some/example/path]
      def path_to_partial_paths(path)
        acc = nil
        path.to_s
            .split('/')
            .map { |p| acc = [*acc, p].join('/') }
      end

      # A twig is a tree with only single branches
      # [a, b, c] =>
      #   {a: {b: {c: {} } } }
      def list_to_twig(items)
        result = {}
        items.inject(result) do |parent, value|
          parent[value] = {}
        end
        result
      end

      #   [{a: {b: {c: {} } } }
      #    {a: {b: {d: {} } } }]
      # => {a: {b: {c: {}, d: {} }}}
      def deep_merge(trees)
        trees.inject do |result, h|
          result.merge(h) { |k, val, val_b| deep_merge([val, val_b]) }
        end
      end

      # {a: {b: {c: {}, d: {} }}}
      # => {b: {c: {}, d: {} }}
      def simplify(tree)
        tree.map do |key, sub_tree|
          sub_tree = simplify(sub_tree)
          key, sub_tree = sub_tree.first if sub_tree.size == 1
          [key, sub_tree]
        end.to_h
      end
    end
  end
end
