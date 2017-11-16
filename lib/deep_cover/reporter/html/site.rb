# frozen_string_literal: true

module DeepCover
  require_relative 'index'
  require_relative 'source'

  module Reporter::HTML
    class Site < Struct.new(:covered_codes, :options)
      include Memoize
      memoize :analysers, :stats, :data_table

      def path
        Pathname(options[:output])
      end

      def save
        clear
        save_assets
        save_index
        save_pages
      end

      def clear
        path.mkpath
        path.rmtree
        path.mkpath
      end

      def compile_stylesheet(source, dest)
        Bundler.with_clean_env do
          `sass #{source} #{dest}`
        end
      end

      def render_index
        Tools.render_template(:index, Index.new(stats))
      end

      def save_index
        path.join('index.html').write(render_index)
      end

      def save_assets
        require 'fileutils'
        src = "#{__dir__}/template/assets"
        dest = path.join('assets')
        FileUtils.cp_r(src, dest)
        compile_stylesheet "#{src}/deep_cover.css.sass", dest.join('deep_cover.css')
      end

      def render_page(covered_code)
        Tools.render_template(:source, Source.new(analysers[covered_code][:per_char]))
      end

      def save_pages
        covered_codes.each do |covered_code|
          dest = path.join("#{covered_code.name}.html")
          dest.dirname.mkpath
          dest.write(render_page(covered_code))
        end
      end

      def analysers
        covered_codes.map do |covered_code|
          [covered_code, compute_analysers(covered_code)]
        end.to_h
      end

      def stats
        analysers.transform_values { |a| a.transform_values(&:stats) }
      end

      def self.save(covered_codes, output: raise, **options)
        Site.new(covered_codes, output: output, **options).save
      end

      private

      def compute_analysers(covered_code)
        base = Analyser::Node.new(covered_code, **options)
        {
          per_char: Analyser::PerChar,
          branch: Analyser::Branch,
        }.transform_values { |klass| klass.new(base, **options) }
          .merge!(node: base)
      end
    end
  end
end
