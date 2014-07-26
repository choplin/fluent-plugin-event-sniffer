module Fluent
  module EventSnifferPlugin
    module EngineUtil
      def self.sniff(pattern, max_events)
        $log.info "start to sniff with pattern '#{pattern}'"

        Engine.instance_eval do
          alias :original_emit_staream :emit_stream
          @sniff_match_pattern = Fluent::MatchPattern.create(pattern)
          @sniff_match_cache = {}
          @sniff_buf = []
          @sniff_max_events = max_events

          def emit_stream(tag, es)
            if @sniff_buf.size < @sniff_max_events
              matched = @sniff_match_cache[tag]

              if matched.nil?
                matched = @sniff_match_pattern.match(tag)
                @sniff_match_cache[tag] = matched
              end

              if matched
                es.dup.each do |time, record|
                  @sniff_buf.push({tag:tag, time:time, record:record})
                end
              end
            end

            original_emit_staream(tag, es)
          end
        end
      end

      def self.restore
        $log.info "restore original Engine"
        Engine.instance_eval do
          alias :emit_stream :original_emit_staream
          undef :original_emit_staream
          @sniff_match_pattern = nil
          @sniff_match_cache = nil
          @sniff_buf = nil
          @sniff_max_events = nil
        end
      end

      def self.get_sniffed_results
        Engine.instance_eval do
          res = @sniff_buf
          @sniff_buf = []
          res
        end
      end
    end
  end
end

