# frozen_string_literal: true

module DeepCover
  module Reporter
    require_relative 'tree'
    class HTML::Index < Struct.new(:stats)
      include HTML::Tree
      def stats_to_data
        @map = Tools.transform_keys(stats, &:name)
        tree = paths_to_tree(@map.keys)
        populate(tree)
      end

      def data_for_path(path)
        data = @map[path].map do |type, stats|
          Tools.transform_keys(stats.to_h) { |kind| :"#{type}_#{kind}" }
        end
        Tools.merge(*data)
      end

      # {a: {}}    => [{text: a, data: stats[a]}]
      # {b: {...}} => [{text: b, data: sum(stats), children: [...]}]
      def populate(tree)
        tree.map do |path, children_hash|
          if children_hash.empty?
            {text: path, data: data_for_path(path)}
          else
            children = populate(children_hash)
            data = Tools.merge(*children.map { |c| c[:data] }, :+)
            {text: path, data: data, children: children}
          end
        end
      end
    end
  end
end
