# Terraform with Auto Scaling for Fargate

This pile of code is designed to provision a simple Nginx webserver and ASG (Auto Scaling Group) with IPv6 and AWS ACM support.

While this is not entirely finished it does attempt to support the newer and fancier tech to achieve faster speeds than by a more traditional stack.

## What could be done better:

* Use Terragrunt to keep the infra DRY.
* Fix the healthcheck for the Nginx fargate container.
* Add scoped IAM permissions for the ASG and Fargate Services, a common attack issue.
* Add cloudwatch metrics and logging, alert if the WAF rules trigger.
* AWS Organisations to secure said logs from tampering and do cool multi-account setup per environment E.G Dev, QA, Prod provisioning.
* Frankly its a rush job and hasn't been cleaned up, for one it needs proper tagging for cost reporting, the other glaring issue is the lack of any useful IAM roles.

## What is implemented:

* Multi AZ support
* Spot instance scaling
* IPv6 support across multi AZs (Dualstack)
* TLS on the load balancer
* Automatic route 53 provisioning of DNS for the ALB and TLS DNS challange

## Why bother with IPv6 and TLS?

Because I thought it would be fun and I didn't expect the ASG and healthchecks to be a slog, I've spent 20 hours on this at this point and am putting it up to hopefully help others learn from it.

Measuring with my own bootleg benchmarking I find IPv6 gives a 20-30 percent speed up on web applications due to the lack of NAT processing, this effect is even greater when combined with TLS as Deep Packet Inspection cannot occur and thus lowering ping times. Additionally without NAT the only thing you need to worry about is Firewall rules and ACLs.