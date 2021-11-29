# This template is designed for deploying an EBS volume from the Morpheus UI. 

# Intentions are to map availability zones to those which an associated ec2 instance sits on
# and also add and attachment resource here to then attach the volume to an ec2 instance chosen
# in an option type drop down by the user at time of creation

locals {
  ebs = "<%=customOptions.ot_advanced%>" == "true" ? 0 : 1
  snapshot = "<%=customOptions.ot_advanced%>" == "true" ? 1 : 0
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
