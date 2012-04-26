class Fluent::CloudwatchInput < Fluent::Input
  Fluent::Plugin.register_input("cloudwatch", self)

  config_param :tag, :string
  config_param :access_key, :string
  config_param :secret_key, :string
  config_param :endpoint, :string, :default => "monitoring.amazonaws.com"

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

    @metrics = conf.elements.select {|e|
      e.name == 'metric'
    }.map {|e|
      {:namespace => e['namespace'],
       :statistics => e['statistics'],
       :dimensions => e['dimensions'],
       :measure_name => e['metric_name']}
    }
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
      Fluent::Engine.emit(tag, Fluent::Engine.now, output)
      sleep 60 * 5
    end
  end

  def output
    end_time = Time.now
    start_time = end_time - 60 * 60
    @metrics.map {|m|
      m[:start_time] = start_time
      m[:end_time] = end_time
      format m, @mon.get_metric_statistics(m)
    }
  end

  def format(m, s)
    d = s["GetMetricStatisticsResult"]["Datapoints"]["member"].sort {|a,b|
      time(a) <=> time(b)
    }.last

    d["MetricName"] = m[:measure_name]
    d["Statistics"] = m[:statistics]
    d["Value"] = d.delete(m[:statistics])
    d
  end

  def time(d)
    Time.parse d["Timestamp"]
  end
end

