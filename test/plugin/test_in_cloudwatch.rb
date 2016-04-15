require 'helper'

class CloudwatchInputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  ### for RDS
  CONFIG_RDS = %[
    tag cloudwatch
    aws_key_id test_key_id
    aws_sec_key test_sec_key
    cw_endpoint test_cloud_watch_endpoint
    namespace AWS/RDS
    metric_name CPUUtilization,FreeStorageSpace,DiskQueueDepth,FreeableMemory,SwapUsage,ReadIOPS,ReadLatency,ReadThroughput,WriteIOPS,WriteLatency,WriteThroughput
    dimensions_name DBInstanceIdentifier
    dimensions_value rds01
  ]

  def create_driver_rds(conf = CONFIG_RDS)
    Fluent::Test::InputTestDriver.new(Fluent::CloudwatchInput).configure(conf)
  end

  def test_configure_rds
    d = create_driver_rds
    assert_equal 'cloudwatch', d.instance.tag
    assert_equal 'test_key_id', d.instance.aws_key_id
    assert_equal 'test_sec_key', d.instance.aws_sec_key
    assert_equal 'test_cloud_watch_endpoint', d.instance.cw_endpoint
    assert_equal 'AWS/RDS', d.instance.namespace
    assert_equal 'CPUUtilization,FreeStorageSpace,DiskQueueDepth,FreeableMemory,SwapUsage,ReadIOPS,ReadLatency,ReadThroughput,WriteIOPS,WriteLatency,WriteThroughput', d.instance.metric_name
    assert_equal 'DBInstanceIdentifier', d.instance.dimensions_name
    assert_equal 'rds01', d.instance.dimensions_value
    assert_equal [{ :name => 'DBInstanceIdentifier', :value => 'rds01' }], d.instance.dimensions
  end


  ### for EC2
  CONFIG_ECTWO = %[
    tag cloudwatch
    aws_key_id test_key_id
    aws_sec_key test_sec_key
    cw_endpoint test_cloud_watch_endpoint
    namespace AWS/EC2
    metric_name CPUUtilization,FreeStorageSpace,DiskQueueDepth,FreeableMemory,SwapUsage,ReadIOPS,ReadLatency,ReadThroughput,WriteIOPS,WriteLatency,WriteThroughput
    dimensions_name InstanceId
    dimensions_value ec2-01
  ]

  def create_driver_ectwo(conf = CONFIG_ECTWO)
    Fluent::Test::InputTestDriver.new(Fluent::CloudwatchInput).configure(conf)
  end

  def test_configure_ectwo
    d = create_driver_ectwo
    assert_equal 'cloudwatch', d.instance.tag
    assert_equal 'test_key_id', d.instance.aws_key_id
    assert_equal 'test_sec_key', d.instance.aws_sec_key
    assert_equal 'test_cloud_watch_endpoint', d.instance.cw_endpoint
    assert_equal 'AWS/EC2', d.instance.namespace
    assert_equal 'CPUUtilization,FreeStorageSpace,DiskQueueDepth,FreeableMemory,SwapUsage,ReadIOPS,ReadLatency,ReadThroughput,WriteIOPS,WriteLatency,WriteThroughput', d.instance.metric_name
    assert_equal 'InstanceId', d.instance.dimensions_name
    assert_equal 'ec2-01', d.instance.dimensions_value
    assert_equal [{ :name => 'InstanceId', :value => 'ec2-01' }], d.instance.dimensions
  end

  ### for StorageGateway
  CONFIG_SG = %[
    tag cloudwatch
    aws_key_id test_key_id
    aws_sec_key test_sec_key
    cw_endpoint test_cloud_watch_endpoint
    namespace AWS/StorageGateway
    metric_name CacheHitPercent,CachePercentUsed
    dimensions_name GatewayId,GatewayName
    dimensions_value sgw-XXXXXXXX,mygateway
  ]

  def create_driver_sg(conf = CONFIG_SG)
    Fluent::Test::InputTestDriver.new(Fluent::CloudwatchInput).configure(conf)
  end

  def test_configure_sg
    d = create_driver_sg
    assert_equal 'cloudwatch', d.instance.tag
    assert_equal 'test_key_id', d.instance.aws_key_id
    assert_equal 'test_sec_key', d.instance.aws_sec_key
    assert_equal 'test_cloud_watch_endpoint', d.instance.cw_endpoint
    assert_equal 'AWS/StorageGateway', d.instance.namespace
    assert_equal 'CacheHitPercent,CachePercentUsed', d.instance.metric_name
    assert_equal 'GatewayId,GatewayName', d.instance.dimensions_name
    assert_equal 'sgw-XXXXXXXX,mygateway', d.instance.dimensions_value
    assert_equal [{ :name => "GatewayId", :value => "sgw-XXXXXXXX" }, { :name => "GatewayName", :value => "mygateway" }], d.instance.dimensions
  end

  ### delayed_start
  CONFIG_DELAYED_START = CONFIG_RDS + %[
    delayed_start true
  ]

  def create_driver_delayed_start(conf = CONFIG_DELAYED_START)
    Fluent::Test::InputTestDriver.new(Fluent::CloudwatchInput).configure(conf)
  end

  def test_configure_delayed_start
    d = create_driver_delayed_start
    assert_equal 'cloudwatch', d.instance.tag
    assert_equal 'test_key_id', d.instance.aws_key_id
    assert_equal 'test_sec_key', d.instance.aws_sec_key
    assert_equal 'test_cloud_watch_endpoint', d.instance.cw_endpoint
    assert_equal 'AWS/RDS', d.instance.namespace
    assert_equal 'CPUUtilization,FreeStorageSpace,DiskQueueDepth,FreeableMemory,SwapUsage,ReadIOPS,ReadLatency,ReadThroughput,WriteIOPS,WriteLatency,WriteThroughput', d.instance.metric_name
    assert_equal 'DBInstanceIdentifier', d.instance.dimensions_name
    assert_equal 'rds01', d.instance.dimensions_value
    assert_equal [{ :name => 'DBInstanceIdentifier', :value => 'rds01' }], d.instance.dimensions
    assert_equal true, d.instance.delayed_start
  end

  ### for CloudWatchLogsMetricFilters
  CONFIG_CWLOG_MF = %[
    tag cloudwatch
    aws_key_id test_key_id
    aws_sec_key test_sec_key
    cw_endpoint test_cloud_watch_endpoint
    namespace LogMetrics
    metric_name LogAccessCount,LogErrorCount
  ]

  def create_driver_cwlog_mf(conf = CONFIG_CWLOG_MF)
     Fluent::Test::InputTestDriver.new(Fluent::CloudwatchInput).configure(conf)
  end

  def test_configure_cwlog_mf
    d = create_driver_cwlog_mf
    assert_equal 'cloudwatch', d.instance.tag
    assert_equal 'test_key_id', d.instance.aws_key_id
    assert_equal 'test_sec_key', d.instance.aws_sec_key
    assert_equal 'test_cloud_watch_endpoint', d.instance.cw_endpoint
    assert_equal 'LogMetrics', d.instance.namespace
    assert_equal 'LogAccessCount,LogErrorCount', d.instance.metric_name
    assert_nil d.instance.dimensions_name
    assert_nil d.instance.dimensions_value
    assert_equal [], d.instance.dimensions
  end
end
