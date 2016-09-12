# encoding: utf-8
require "logstash/namespace"
require "logstash/outputs/base"
require "socket"
require "wavefront/writer"

# ==== The Wavefront Output Plugin for Logstash
# Every event processed by this plugin has all of its fields scanned. If those
# fields contain hashes, and those hashes have keys that match "metrics" below,
# they are sent to Wavefront.
#
# For example, suppose you give the following config:
# ----
# output {
#   wavefront {
#     prefix => "mymetrics"
#     metrics => ["count", "mean"]
#   }
# }
# ----
#
# Then, the following event...
# ----
# {
#   "data1" => {
#     "count" => 200,
#     "mean" => 42.2
#   },
#   "data2" => {
#     "count" => 123,
#     "max" => 9001
#   },
#   "data3" => "I'm not a hash, so I'm not even parsed."
# }
# ----
#
# Will report the following metrics to Wavefront:
#
# * `mymetrics.data1.count 200`
# * `mymetrics.data1.mean 42.2`
# * `mymetrics.data2.count 123`
#
# This scheme allows you to easily integrate with the
# <<plugins-filters-metrics,metrics filter plugin>>, but integration with any
# other filter should be possible with mutates and groks.
#
# ==== The Wavefront Proxy
# This plugin is designed to send telemetry to the
# https://github.com/wavefrontHQ/java/tree/master/proxy[Wavefront Proxy]
# (https://github.com/wavefrontHQ/install[installation instructions]).
class LogStash::Outputs::Wavefront < LogStash::Outputs::Base
  config_name "wavefront"

  # The hostname or IP of a running Wavefront Proxy.
  config :host, :validate => :string, :default => "localhost"
  # The port that the Wavefront Proxy is listening on.
  config :port, :validate => :number, :default => 2878
  # The Wavefront UI will show all telemetry as coming from this "source". If
  # empty, we will use the hostname of the node running logstash.
  config :source, :validate => :string, :default => ""
  # The metrics to parse out of incoming events, as described above.
  config :metrics, :validate => :array, :default => ["count", "mean"]
  # A special string to insert before every incoming metric before sending to
  # WF. May be blank, in which case we will use no special prefix.
  config :prefix, :validate => :string, :default => ""
  # A special string that allows you to tag your outgoing metrics. For example,
  # the following event:
  # ----
  # {
  #   "data1.tagz.zone=abc.class=123" => {
  #     "count" => 200
  #   }
  # }
  # ----
  #
  # Will send the following metric to WF:
  #
  # * `data1.count 200 zone=abc class=123`
  config :tag_separator, :validate => :string, :default => "tagz"

  # Access to these fields is provided for testing only!
  attr_reader :source

  public
  def register
    if @source == ""
      @source = Socket.gethostname
    end
    @open = false
  end

  private
  def try_set_writer()
    begin
      @writer = Wavefront::Writer.new({
        :agent_host => @host,
        :agent_port => @port,
        :host_name => @source
      })
    rescue Errno::ECONNREFUSED
      @logger.error("Could not connect to wavefront proxy!")
      return false
    end
    return true
  end

  public
  def receive(event)
    if not @open
      if not try_set_writer
        @logger.error("Dropping point, connection to WF agent is down.")
        return
      else
        @open = true
      end
    end

    event.to_hash.each do |faux_metric_name, field_value|
      next if field_value.class != Hash

      # Parse out tags if any are encoded in the metric name.
      parts = faux_metric_name.split(".")
      tags = {}
      if parts.length == 1 || @tag_separator == ""
          metric_name = faux_metric_name
      else
          idx = parts.index(@tag_separator)
          if idx == nil
            metric_name = faux_metric_name
          else
              metric_name = parts.slice(0, idx).join(".")
              parts.slice(idx + 1, parts.length - 1).each do |keyvalue|
                  tag_parts = keyvalue.split("=")
                  if tag_parts.length <= 1
                      next
                  else
                      tags[tag_parts[0]] = tag_parts.slice(1, tag_parts.length).join("=")
                  end
              end
          end
      end

      field_value.each do |metric_specifier, metric_value|
        full_metric = "#{metric_name}.#{metric_specifier}"
        if @metrics.include? metric_specifier
          full_metric_name =\
            @prefix == "" ? full_metric : "#{@prefix}.#{full_metric}"
          @logger.debug? && logger.debug(
              "Sending #{full_metric_name}=#{metric_value}: #{tags}")
          begin
            @writer.write(metric_value, full_metric_name, {:point_tags => tags})
          rescue Errno::EPIPE
            @logger.error("Connection to WF agent dropped!")
            @open = false
            return
          end
        else
          @logger.debug? && logger.debug(
              "Skipping unmentioned metric #{metric_specifier}")
        end
      end
    end
  end # def receive

end # class Wavefront
