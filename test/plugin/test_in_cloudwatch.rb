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
  end

end
