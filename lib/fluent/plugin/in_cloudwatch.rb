class Fluent::CloudwatchInput < Fluent::Input
  Fluent::Plugin.register_input("cloudwatch", self)

  config_param :tag,               :string
  config_param :aws_key_id,        :string, :default => nil
  config_param :aws_sec_key,       :string, :default => nil
  config_param :cw_endpoint,       :string, :default => nil

  config_param :namespace,         :string, :default => nil
  config_param :metric_name,       :string, :default => nil
  config_param :statistics,        :string, :default => "Average"
  config_param :dimensions_name,   :string, :default => nil
  config_param :dimensions_value,  :string, :default => nil
  config_param :period,            :integer, :default => 60
  config_param :interval,          :integer, :default => 60


   def initialize
    super
    require 'aws-sdk'
  end

  def configure(conf)
    super
    @cw = AWS::CloudWatch.new(
      :access_key_id        => @aws_key_id,
      :secret_access_key    => @aws_sec_key,
      :cloud_watch_endpoint => @cw_endpoint
    ).client
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
      sleep @interval
      output
    end
  end

  def output
    @metric_name.split(",").each {|m|
      statistics = @cw.get_metric_statistics({
        :namespace   => @namespace,
        :metric_name => m,
        :statistics  => [@statistics],
        :dimensions  => [{
          :name  => @dimensions_name,
          :value => @dimensions_value
        }],
        :start_time  => (Time.now - 120).iso8601,
        :end_time    => Time.now.iso8601,
        :period      => @period
      })
      unless statistics[:datapoints].empty?
        stat = @statistics.downcase.to_sym
        data = statistics[:datapoints][0][stat]

        # unix time
        catch_time = statistics[:datapoints][0][:timestamp].to_i

        # no output_data.to_json
        output_data = {m => data}
        Fluent::Engine.emit(tag, catch_time, output_data)
      end
    }
    sleep 1
  end
end
