data "aws_eip" "allocation_id" {
  id = aws_eip.lc_www1_eip.id
}
