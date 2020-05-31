# google-cloud-module (Maryna Yantsevich' report)
## 1. Create the following configuration via terraform:
<p align="center">
  <img src="Images/0.png" width="700px" />
</p>

## 2. README.md✌
Bootstrap of this infrastructure should be started from main.tf. \
Main.tf invokes 7 modules: 6 local and 1 GCE module:
<p align="left">
  <img src="Images/1.1.png" width="200px" />
</p>

  - Module 'network' describes vpc, subnets and firewall rules and passes values vpc, private/public subnet to output.
  - Modules 'ig' and 'internal-ig' describe instance groups, their templates and managers. These modules have a group name and group manager as output.
  - Module 'bastion' describe instance, which has inbound access at port 22 and outbound route to the private subnet.
  - Modules 'internal-lb' and external module 'gce-lb-http' describe 2 load balancers (HTTP and Network), which balance load to nginx nodes and db nodes (in future, but nginx nodes now).
  - Module 'autoscaler' should be used with 'ig' module. This module describes rules of autoscaling for the first instance group.

 Also, infrastructure uses google_storage_bucket, to use it please, add Google Cloud Storage API to your GCP.

If something wasn't applied from bootstrap, please, repeat applying once again without destroying :)


## 3. A few screenshots
<p align="center">
  <img src="Images/1.png" width="700px" />
</p>

<p align="center">
  <img src="Images/7.jpg" width="700px" />
</p>

<p align="center">
  <img src="Images/8.jpg" width="700px" />
</p>

<p align="center">
  <img src="Images/2.png" width="700px" />
</p>

<p align="center">
  <img src="Images/3.png" width="700px" />
</p>

<p align="center">
  <img src="Images/4.png" width="700px" />
</p>

<p align="center">
  <img src="Images/5.png" width="700px" />
</p>

<p align="center">
  <img src="Images/6.png" width="700px" />
</p>

