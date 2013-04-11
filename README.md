# fluent-plugin-cloudwatch


## Overview
***AWS CloudWatch*** input plugin.  

this plugin is simple.  
get metrics from cloudwatch.

1. get every 60 seconds from AWS CloudWatch API(sleep 1sec)
2. 60 seconds of data

## Configuration

```config
<source>
  type cloudwatch
  tag cloudwatch
  aws_key_id  YOUR_AWS_KEY_ID
  aws_sec_key YOUR_AWS_SECRET_KEY
  cw_endpoint ENDPOINT

  namespace        [namespace]
  statistics       [statistics] (default: Average)
  metric_name      [metric name]
  dimensions_name  [dimensions_name]
  dimensions_value [dimensions value]
  period           [period] (default: 60)
  interval         [interval] (default: 60)
</source>

```

### GET RDS Metric

```config
<source>
  type cloudwatch
  tag  cloudwatch
  aws_key_id  YOUR_AWS_KEY_ID
  aws_sec_key YOUR_AWS_SECRET_KEY
  cw_endpoint monitoring.ap-northeast-1.amazonaws.com

  namespace AWS/RDS
  metric_name CPUUtilization,FreeStorageSpace,DiskQueueDepth,FreeableMemory,SwapUsage,ReadIOPS,ReadLatency,ReadThroughput,WriteIOPS,WriteLatency,WriteThroughput
  dimensions_name DBInstanceIdentifier
  dimensions_value rds01
</source>

<match cloudwatch>
  type copy
 <store>
  type file
  path /var/log/td-agent/test
 </store>
</match>

```

#### output data format

```
2013-02-24T13:40:00+09:00       cloudwatch      {"CPUUtilization":2.0}
2013-02-24T13:40:00+09:00       cloudwatch      {"FreeStorageSpace":104080723968.0}
2013-02-24T13:39:00+09:00       cloudwatch      {"DiskQueueDepth":0.002000233360558732}
2013-02-24T13:40:00+09:00       cloudwatch      {"FreeableMemory":6047948800.0}
2013-02-24T13:40:00+09:00       cloudwatch      {"SwapUsage":0.0}
2013-02-24T13:40:00+09:00       cloudwatch      {"ReadIOPS":0.4832769510223807}
2013-02-24T13:40:00+09:00       cloudwatch      {"ReadLatency":0.0}
2013-02-24T13:39:00+09:00       cloudwatch      {"ReadThroughput":0.0}
2013-02-24T13:40:00+09:00       cloudwatch      {"WriteIOPS":5.116069791857616}
2013-02-24T13:40:00+09:00       cloudwatch      {"WriteLatency":0.004106280193236715}
2013-02-24T13:39:00+09:00       cloudwatch      {"WriteThroughput":54074.40992132284}
```


### GET ELB Metirc

```config
<source>
  type cloudwatch
  tag  cloudwatch
  aws_key_id  YOUR_AWS_KEY_ID
  aws_sec_key YOUR_AWS_SECRET/KE
  cw_endpoint monitoring.ap-northeast-1.amazonaws.com

  namespace AWS/ELB
  metric_name HealthyHostCount,HTTPCode_Backend_2XX,HTTPCode_Backend_3XX,HTTPCode_Backend_4XX,HTTPCode_Backend_5XX,HTTPCode_ELB_4XX,Latency,RequestCount,UnHealthyHostCount
  dimensions_name LoadBalancerName
  dimensions_value YOUR_ELB_NAME
</source>
```

#### output data format

```

2013-03-21T14:08:00+09:00       cloudwatch      {"HealthyHostCount":2.0}
2013-03-21T14:08:00+09:00       cloudwatch      {"HTTPCode_Backend_2XX":1.0}
2013-03-21T14:08:00+09:00       cloudwatch      {"Latency":0.004025}
2013-03-21T14:08:00+09:00       cloudwatch      {"RequestCount":1.0}
2013-03-21T14:09:00+09:00       cloudwatch      {"UnHealthyHostCount":0.0}

```


### GET EC2 Metirc

```config
<source>
  type cloudwatch
  tag  cloudwatch
  aws_key_id  YOUR_AWS_KEY_ID
  aws_sec_key YOUR_AWS_SECRET/KE
  cw_endpoint monitoring.ap-northeast-1.amazonaws.com

  namespace AWS/EC2
  metric_name CPUUtilization,FreeStorageSpace,DiskQueueDepth,FreeableMemory,SwapUsage,ReadIOPS,ReadLatency,ReadThroughput,WriteIOPS,WriteLatency,WriteThroughput
  dimensions_name InstanceId
  dimensions_value YOUR_INSTANCE_ID
</source>
```

#### output data format

```

2013-02-25T00:44:00+09:00       cloudwatch      {"CPUUtilization":1.58}
2013-02-25T00:44:00+09:00       cloudwatch      {"DiskReadBytes":0.0}
2013-02-25T00:44:00+09:00       cloudwatch      {"DiskReadBytes":0.0}
2013-02-25T00:44:00+09:00       cloudwatch      {"DiskWriteBytes":0.0}
2013-02-25T00:44:00+09:00       cloudwatch      {"DiskWriteOps":0.0}
2013-02-25T00:44:00+09:00       cloudwatch      {"NetworkIn":95183.0}
2013-02-25T00:44:00+09:00       cloudwatch      {"NetworkOut":95645.0}

```

### GET DynamoDB Metirc

```config
  type cloudwatch
  tag  cloudwatch
  aws_key_id  YOUR_AWS_KEY_ID
  aws_sec_key YOUR_AWS_SECRET/KE
  cw_endpoint monitoring.ap-northeast-1.amazonaws.com

  namespace AWS/DynamoDB
  metric_name ConsumedReadCapacityUnits,ConsumedWriteCapacityUnits
  dimensions_name TableName
  dimensions_value ppc-production-visit
  statistics Sum 
  interval 300
  period 300
```

#### output data format

```

2013-04-11 15:13:00 +0900       cloudwatch      {"ConsumedReadCapacityUnits":8271.5}
2013-04-11 15:13:00 +0900       cloudwatch      {"ConsumedWriteCapacityUnits":2765.5}

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
