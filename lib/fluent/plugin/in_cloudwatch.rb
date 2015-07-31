class Fluent::CloudwatchInput < Fluent::Input
  Fluent::Plugin.register_input("cloudwatch", self)

  # To support log_level option implemented by Fluentd v0.10.43
  unless method_defined?(:log)
    define_method("log") { $log }
  end

  # Define `router` method of v0.12 to support v0.10 or earlier
  unless method_defined?(:router)
    define_method("router") { Fluent::Engine }
  end

  config_param :tag,               :string
  config_param :aws_key_id,        :string, :default => nil, :secret => true
  config_param :aws_sec_key,       :string, :default => nil, :secret => true
  config_param :cw_endpoint,       :string, :default => nil

  config_param :namespace,         :string, :default => nil
  config_param :metric_name,       :string, :default => nil
  config_param :statistics,        :string, :default => "Average"
  config_param :dimensions_name,   :string, :default => nil
  config_param :dimensions_value,  :string, :default => nil
  config_param :period,            :integer, :default => 300
  config_param :interval,          :integer, :default => 300
  config_param :open_timeout,      :integer, :default => 10
  config_param :read_timeout,      :integer, :default => 30
  config_param :delayed_start,     :bool,    :default => false

  attr_accessor :dimensions

  def initialize
    super
    require 'aws-sdk-v1'
  end

  def configure(conf)
    super

    @dimensions = []
    if @dimensions_name && @dimensions_value
      names = @dimensions_name.split(",").each
      values = @dimensions_value.split(",").each
      loop do
        @dimensions.push({
          :name => names.next,
          :value => values.next,
        })
      end
    else
      @dimensions.push({
        :name => @dimensions_name,
        :value => @dimensions_value,
      })
    end

    AWS.config(
      :http_open_timeout => @open_timeout,
      :http_read_timeout => @read_timeout,
    )
  end

  def start
    super

    @running = true
    @updated = Time.now
    @watcher = Thread.new(&method(:watch))
    @monitor = Thread.new(&method(:monitor))
    @mutex   = Mutex.new
  end

  def shutdown
    super
    @running = false
    @watcher.terminate
    @monitor.terminate
    @watcher.join
    @monitor.join
  end

  private

  # if watcher thread was not update timestamp in recent @interval * 2 sec., restarting it.
  def monitor
    log.debug "cloudwatch: monitor thread starting"
    while @running
      sleep @interval / 2
      @mutex.synchronize do
        log.debug "cloudwatch: last updated at #{@updated}"
        now = Time.now
        if @updated < now - @interval * 2
          log.warn "cloudwatch: watcher thread is not working after #{@updated}. Restarting..."
          @watcher.kill
          @updated = now
          @watcher = Thread.new(&method(:watch))
        end
      end
    end
  end

  def watch
    if @delayed_start
      delay = rand() * @interval
      log.debug "cloudwatch: delay at start #{delay} sec"
      sleep delay
    end

    @cw = AWS::CloudWatch.new(
      :access_key_id        => @aws_key_id,
      :secret_access_key    => @aws_sec_key,
      :cloud_watch_endpoint => @cw_endpoint,
    ).client

    output

    started = Time.now
    while @running
      now = Time.now
      sleep 1
      if now - started >= @interval
        output
        started = now
        @mutex.synchronize do
          @updated = Time.now
        end
      end
    end
  end

  def output
    @metric_name.split(",").each {|m|
      statistics = @cw.get_metric_statistics({
        :namespace   => @namespace,
        :metric_name => m,
        :statistics  => [@statistics],
        :dimensions  => @dimensions,
        :start_time  => (Time.now - @period*10).iso8601,
        :end_time    => Time.now.iso8601,
        :period      => @period,
      })
      unless statistics[:datapoints].empty?
        stat = @statistics.downcase.to_sym
        datapoint = statistics[:datapoints].sort_by{|h| h[:timestamp]}.last
        data = datapoint[stat]

        # unix time
        catch_time = datapoint[:timestamp].to_i

        # no output_data.to_json
        output_data = {m => data}
        router.emit(tag, catch_time, output_data)
      else
        log.warn "cloudwatch: #{@namespace} #{@dimensions_name} #{@dimensions_value} #{m} datapoints is empty"
      end
    }
  end
end
