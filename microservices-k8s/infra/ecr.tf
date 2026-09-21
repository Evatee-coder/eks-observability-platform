# 
resource "aws_ecr_repository" "images" {
  for_each = local.services

  name                 = "${var.environment}-${var.app_name}-${each.key}"
  force_delete         = true # ✅ add this line
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = each.key
  }
}


# [id=216989097838.dkr.ecr.us-east-1.amazonaws.com/prod-craftica-frontend]
# [id=216989097838.dkr.ecr.us-east-1.amazonaws.com/prod-craftica-catalogue]
# [id=216989097838.dkr.ecr.us-east-1.amazonaws.com/prod-craftica-voting]
# [id=216989097838.dkr.ecr.us-east-1.amazonaws.com/prod-craftica-recco]


# frontend.prod.eva-tee.com
# catalogue.prod.eva-tee.com
# voting.prod.eva-tee.com
# recco.prod.eva-tee.com
# *.prod.eva-tee.com