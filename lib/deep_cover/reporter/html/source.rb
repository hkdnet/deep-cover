# frozen_string_literal: true

module DeepCover
  class Reporter::HTML::Source < Struct.new(:analyser)
    def convert
      @rewriter = ::Parser::Source::Rewriter.new(covered_code.buffer)
      insert_tags
      html_escape
      @rewriter.process
    end

    def root_path
      Pathname('.').relative_path_from(Pathname(covered_code.name).dirname)
    end

    def covered_code
      analyser.covered_code
    end

    private

    def node_attributes(node, kind)
      title, run = case runs = analyser.node_runs(node)
                   when nil
                     ['ignored', 'ignored']
                   when 0
                     ['never run', 'not-run']
                   else
                     ["#{runs}x", 'run']
      end
      %{class="node-#{node.type} kind-#{kind} #{run}" title="#{title}"}
    end

    def insert_tags
      analyser.each_node do |node, _children|
        node.executed_loc_hash.each do |kind, range|
          @rewriter.insert_before_multi(range, "<span #{node_attributes(node, kind)}>")
          @rewriter.insert_after_multi(range, '</span>')
        end
      end
    end

    def each_match(source, pattern) # Is there really no builtin way to do this??
      prev = 0
      while (m = source.match(pattern, prev))
        yield m
        prev = m.end(0)
      end
    end

    def html_escape
      buffer = analyser.covered_code.buffer
      source = buffer.source
      {'<' => '&lt;', '>' => '&gt;', '&' => '&amp;'}.each do |char, escaped|
        each_match(source, char) do |match|
          @rewriter.replace(::Parser::Source::Range.new(buffer, match.begin(0), match.end(0)), escaped)
        end
      end
    end
  end
end
