class Fluent::CloudwatchInput < Fluent::Input
  Fluent::Plugin.register_input("cloudwatch", self)

  config_param :tag, :string
  config_param :access_key, :string
  config_param :secret_key, :string
  config_param :endpoint, :string, :default => "monitoring.amazonaws.com"
  config_param :namespace, :string
  config_param :statistics, :string
  config_param :dimensions, :string
  config_param :metric_name, :string

  def initialize
    super
    require 'rubygems'
    require 'AWS'
    require 'time'
  end

  def configure(conf)
    super
    @mon = AWS::Cloudwatch::Base.new(
      :access_key_id => access_key,
      :secret_access_key => secret_key,
      :server => endpoint)
  end

  def start
    super
    @watcher = Thread.new(&method(:watch))
  end

  def shutdown
    super
    @watcher.terminate
    @watcher.join
  end

  private
  def watch
    while true
      t, d = output
      Fluent::Engine.emit(tag, t, d)
      sleep 60 * 5
    end
  end

  def output
    end_time = Time.now
    start_time = end_time - 60 * 60
    stat = @mon.get_metric_statistics(
      :namespace => namespace,
      :statistics => statistics,
      :dimensions => dimensions,
      :measure_name => metric_name,
      :start_time => start_time,
      :end_time => end_time)

    format(stat)
  end

  def format(s)
    d = s["GetMetricStatisticsResult"]["Datapoints"]["member"].sort {|a,b|
      time(a) <=> time(b)
    }.last

    t = Time.parse d.delete("Timestamp")
    d["MetricName"] = metric_name
    d["Statistics"] = statistics
    d["Value"] = d.delete(statistics)
    [t, d]
  end

  def time(d)
    Time.parse d["Timestamp"]
  end
end

