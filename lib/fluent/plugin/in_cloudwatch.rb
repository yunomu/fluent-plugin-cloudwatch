require 'fluent/input'
require 'aws-sdk-cloudwatch'
require 'uri'

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
  config_param :aws_use_sts,       :bool,   :default => false
  config_param :aws_sts_role_arn,  :string, :default => nil
  config_param :aws_sts_session_name, :string, :default => 'fluentd'
  config_param :cw_endpoint,       :string, :default => nil
  config_param :region,            :string, :default => nil

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
  config_param :offset,            :integer, :default => 0
  config_param :emit_zero,         :bool,    :default => false
  config_param :record_attr,       :hash,    :default => {}

  attr_accessor :dimensions

  def initialize
    super
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
    elsif @dimensions_name || @dimensions_value
      @dimensions.push({
        :name => @dimensions_name,
        :value => @dimensions_value,
      })
    end

    endpoint = URI(@cw_endpoint)
    if endpoint.scheme != "http" && endpoint.scheme != "https"
      @cw_endpoint_uri = "https://#{@cw_endpoint}"
    else
      @cw_endpoint_uri = endpoint.to_s
    end

    if !@region
      @region = @cw_endpoint.split('.')[1]
    end
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
    log.debug "cloudwatch: watch thread starting"
    if @delayed_start
      delay = rand() * @interval
      log.debug "cloudwatch: delay at start #{delay} sec"
      sleep delay
    end

    if @aws_use_sts
      credentials_options = {
        role_arn: @aws_sts_role_arn,
        role_session_name: @aws_sts_session_name
      }
      if @region
        credentials_options[:client] = Aws::STS::Client.new(:region => @region)
      end
      client_param_credentials = Aws::AssumeRoleCredentials.new(credentials_options)
    else
      client_param_credentials = Aws::Credentials.new(@aws_key_id, @aws_sec_key) if @aws_key_id && @aws_sec_key
    end

    @cw = Aws::CloudWatch::Client.new(
      :region            => @region,
      :credentials       => client_param_credentials,
      :endpoint          => @cw_endpoint_uri,
      :http_open_timeout => @open_timeout,
      :http_read_timeout => @read_timeout,
    )
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
      name, s = m.split(":")
      s ||= @statistics
      now = Time.now - @offset
      log.debug("now #{now}")
      statistics = @cw.get_metric_statistics({
        :namespace   => @namespace,
        :metric_name => name,
        :statistics  => [s],
        :dimensions  => @dimensions,
        :start_time  => (now - @period*10).iso8601,
        :end_time    => now.iso8601,
        :period      => @period,
      })
      if not statistics[:datapoints].empty?
        datapoint = statistics[:datapoints].sort_by{|h| h[:timestamp]}.last
        data = datapoint[s.downcase.to_sym]

        # unix time
        catch_time = datapoint[:timestamp].to_i
        router.emit(tag, catch_time, { name => data }.merge(@record_attr))
      elsif @emit_zero
        router.emit(tag, now.to_i, { name => 0 }.merge(@record_attr))
      else
        log.warn "cloudwatch: #{@namespace} #{@dimensions_name} #{@dimensions_value} #{name} #{s} datapoints is empty"
      end
    }
  end
end
