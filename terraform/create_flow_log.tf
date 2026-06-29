locals {
  csw_vpc_flow_log_format = "$${version} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${tcp-flags} $${interface-id} $${log-status} $${flow-direction} $${pkt-srcaddr} $${pkt-dstaddr}"
}

resource "aws_flow_log" "secureworkload" {
  log_destination      = data.aws_s3_bucket.flowlogs.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.vpc.id

  log_format               = local.csw_vpc_flow_log_format
  max_aggregation_interval = 60

  destination_options {
    file_format                = "plain-text"
    hive_compatible_partitions = false
    per_hour_partition         = true
  }
}
