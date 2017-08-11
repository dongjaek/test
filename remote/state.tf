resource "aws_s3_bucket" "state_bucket" {
  bucket = "${var.bucket_name}"
  acl    = "private"
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name        = "${var.bucket_name}"
    Environment = "${var.environment}"
  }
}

resource "aws_dynamodb_table" "state_lock" {
   name = "${var.table_name}"
   hash_key = "LockID"
   read_capacity = 20
   write_capacity = 20

   attribute {
      name = "LockID"
      type = "S"
   }

   tags {
     Name = "${var.table_name}"
   }
}

output "s3_bucket_arn" {
  value = "${aws_s3_bucket.state_bucket.arn}"
}

output "dynamo_table_arn" {
  value = "${aws_dynamodb_table.state_lock.arn}"
}
