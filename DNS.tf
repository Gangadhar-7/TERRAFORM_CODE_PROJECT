
# Create a new A record that points to the Load balancer.
data "aws_route53_zone" "mydomain" {
  name = "gangadharrecruitcrm.shop"

}

#zoneid

output "mydomain_zoneid" {
  description = "The hosted zone id of the desired hosted zone"
  value       = data.aws_route53_zone.mydomain.zone_id
}


resource "aws_route53_record" "new_record" {
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = "www.gangadharrecruitcrm.shop"
  type    = "A"
  alias {
    name                   = aws_lb.app-lb.dns_name
    zone_id                = aws_lb.app-lb.zone_id
    evaluate_target_health = true
  }
}

