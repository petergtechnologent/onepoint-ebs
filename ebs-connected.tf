# This template is designed for deploying an EBS volume from the Morpheus UI. 

# Intentions are to map availability zones to those which an associated ec2 instance sits on
# and also add and attachment resource here to then attach the volume to an ec2 instance chosen
# in an option type drop down by the user at time of creation

locals {
  ebs = "<%=customOptions.ot_advanced%>" == "true" ? 0 : local.ec2_instance_count
  snapshot = "<%=customOptions.ot_advanced%>" == "true" ? local.ec2_instance_count : 0
  volume_id = local.snapshot == local.ec2_instance_count ? aws_ebs_volume.snapshot : aws_ebs_volume.ebs
}

resource "aws_ebs_volume" "ebs" {
  count = local.ebs
  availability_zone = "<%=customOptions.ot_availability_zone%>"
  size              = "<%=customOptions.ot_size_gb%>"
}

data "aws_ebs_snapshot" "snapshot" {
  count = local.snapshot
  snapshot_ids = ["<%=customOptions.ot_snapshot_id%>"]
}

resource "aws_ebs_volume" "snapshot" {
  count = local.snapshot
  availability_zone = "<%=customOptions.ot_availability_zone%>"
  size              = data.aws_ebs_snapshot.snapshot[0].volume_size
  snapshot_id       = "<%=customOptions.ot_snapshot_id%>"
}

resource "aws_volume_attachment" "ebs_att" {
  count = local.ec2_instance_count
  device_name = "/dev/sdh"
  volume_id   = local.volume_id[count.index].id
  instance_id = aws_instance.ec2[count.index].id
