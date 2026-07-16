# Constructing a Segmented Three-Layer VPC Environment in AWS

# Three-Tier Amazon VPC Architecture

## Project Overview

This project demonstrates the design and deployment of a production-style three-tier Amazon VPC architecture from the ground up using AWS best practices. The environment consists of public (web), private application, and private database tiers, providing a secure, scalable, and highly organized network infrastructure.

The implementation focuses on network segmentation, IP address planning, secure routing, and controlled traffic flow between application layers. Core AWS networking components—including custom VPCs, public and private subnets, route tables, an Internet Gateway, a NAT Gateway, and Network ACLs (NACLs)—are configured to deliver secure connectivity while enforcing least-privilege network access.

---

## Objectives

- Design a secure three-tier AWS network architecture.
- Implement public and private subnet segmentation.
- Configure secure internet connectivity using an Internet Gateway and NAT Gateway.
- Control network traffic using Route Tables and Network ACLs.
- Apply AWS networking and security best practices.
- Build a reusable infrastructure suitable for production environments.

---

## Technologies Used

- Amazon VPC
- Public & Private Subnets
- Route Tables
- Internet Gateway (IGW)
- NAT Gateway
- Network ACLs (NACLs)
- IPv4 CIDR Planning
- AWS Console / cloudformation (optional)

---

## Skills Demonstrated

- AWS Network Architecture
- VPC Design and Deployment
- CIDR Planning and Subnetting
- Network Segmentation
- Secure Routing Configuration
- Internet and Private Connectivity
- Layered Network Security
- AWS Security Best Practices
- Infrastructure Design
  
<img width="1024" height="559" alt="image" src="https://github.com/user-attachments/assets/95e84766-4db9-4274-b019-b09b6286c011" />


## Walkthrough

### Stage One: Provision the VPC
Confirm you're working in the **us-west-2** Region, then open the VPC console.

1. Choose **Your VPCs** from the left-hand navigation, then select **Create VPC**
2. Under VPC settings, choose **VPC only**
3. Give it a name tag if you'd like one
4. For the IPv4 CIDR block, choose **IPv4 CIDR manual input**
5. Enter `10.20.0.0/16` in the IPv4 CIDR field
6. For IPv6, select **No IPv6 CIDR block**
7. Leave Tenancy set to **Default**
8. Set VPC encryption control to **None**
9. Select **Create VPC**

### Stage Two: Lay Out and Build the Subnets
With the VPC in place, it's time to carve out the six subnets across the three layers.

1. Go to **Subnets** and select **Create subnet**
2. Choose your newly built VPC from the dropdown

Create each of the following, using **Add new subnet** to continue after the first:

| Subnet Name | Availability Zone | CIDR Block |
|---|---|---|
| frontend-sn-2a | us-west-2a | 10.20.0.0/27 |
| frontend-sn-2b | us-west-2b | 10.20.0.32/27 |
| midtier-sn-2a | us-west-2a | 10.20.0.64/27 |
| midtier-sn-2b | us-west-2b | 10.20.0.96/27 |
| data-sn-2a | us-west-2a | 10.20.0.128/27 |
| data-sn-2b | us-west-2b | 10.20.0.160/27 |

Once all six are entered, review and click **Create subnet**.

### Stage Three: Stand Up the Internet Gateway and NAT Gateway
Now deploy the components needed for internet reachability.

1. Go to **Internet gateways** and select **Create internet gateway**
2. Name it `edge-igw` and select **Create internet gateway**
3. Once created, open the **Actions** dropdown and choose **Attach to VPC**
4. Pick your custom VPC and select **Attach internet gateway**

Next, build the NAT gateway:

1. Go to **NAT gateways** and select **Create NAT gateway**
2. Name it `edge-nat-gw`
3. Set **Availability mode** to **Regional** (this automatically provides high availability for private-subnet outbound traffic)
4. Choose your custom VPC
5. Confirm **Connectivity type** is **Public**
6. Leave EIP allocation set to **Automatic**, then select **Create NAT gateway**

Record the NAT gateway ID and wait until its state shows **Available** before continuing — this can take a few minutes.

### Stage Four: Build Out the Route Tables
With the groundwork laid, configure routing for each of the three layers.

**Front-end route table**
1. Go to **Route tables** and select **Create route table**
2. Name it `frontend-rt`, attach it to your VPC, and select **Create route table**
3. On the **Routes** tab, select **Edit routes**
4. Add a route: Destination `0.0.0.0/0`, Target **Internet Gateway** → `edge-igw`, then save
5. On **Subnet associations**, select **Edit subnet associations**, check both `frontend-sn-2a` and `frontend-sn-2b`, and save

**Mid-tier route table**
1. Select **Create route table** again, name it `midtier-rt`, attach your VPC, and create it
2. On **Routes**, add: Destination `0.0.0.0/0`, Target **NAT Gateway** → `edge-nat-gw`, then save
3. On **Subnet associations**, associate `midtier-sn-2a` and `midtier-sn-2b`

**Data layer route table**
1. Create one more route table named `data-rt`, attached to your VPC
2. On **Subnet associations**, associate `data-sn-2a` and `data-sn-2b`
3. *(No additional route is added here — only the default local `10.20.0.0/16` route remains, so this layer has no path to the internet.)*

### Stage Five: Configure the Network ACLs
NACLs sit at the subnet boundary and act as your first checkpoint for inbound traffic and your final checkpoint for outbound traffic. Unlike security groups, they're stateless — every direction needs its own explicit rule, and rule numbers determine evaluation order.

For this exercise you'll open up PostgreSQL traffic on port 5432. (For reference, MySQL commonly runs on 3306 and MS SQL on 1433.)

**Front-end NACL**
1. Go to **Network ACLs** and select **Create network ACL**
2. Name it `frontend-nacl`, attach your VPC, and create it
3. Notice that new custom NACLs deny all traffic by default
4. Under **Inbound rules**, add rule #100: Type **All traffic**, Source `0.0.0.0/0`, **Allow**
5. Under **Outbound rules**, add rule #100: Type **All traffic**, Destination `0.0.0.0/0`, **Allow**
6. Under **Subnet associations**, associate `frontend-sn-2a` and `frontend-sn-2b`

**Mid-tier NACL**
1. Create a new NACL named `midtier-nacl`, attached to your VPC
2. Under **Inbound rules**:
   - Rule #100: Type **Custom TCP**, Port range `1024-65535`, Source `0.0.0.0/0`, **Allow** *(ephemeral ports are required for return traffic from things like external web calls or patch downloads)*
   - Rule #200: Type **All traffic**, Source `10.20.0.0/16`, **Allow**
3. Under **Outbound rules**, add rule #100: Type **All traffic**, Destination `0.0.0.0/0`, **Allow**
4. Under **Subnet associations**, associate `midtier-sn-2a` and `midtier-sn-2b`

**Data layer NACL**
1. Create a new NACL named `data-nacl`, attached to your VPC
2. Under **Inbound rules**:
   - Rule #100: Type **PostgreSQL**, Port range `5432`, Source `10.20.0.64/27` (midtier-sn-2a CIDR), **Allow**
   - Rule #110: Type **PostgreSQL**, Port range `5432`, Source `10.20.0.96/27` (midtier-sn-2b CIDR), **Allow**
3. Under **Outbound rules**, add rule #100: Type **All traffic**, Destination `0.0.0.0/0`, **Allow**
4. Under **Subnet associations**, associate `data-sn-2a` and `data-sn-2b`

*(This configuration means the data layer only accepts inbound traffic from the mid-tier subnets on the database port, keeping it fully shielded from direct internet exposure.)*

### Stage Six (Optional): Confirm Traffic Behavior End-to-End
As an optional stretch goal, launch a test instance in each layer to confirm routing, egress, and NACL enforcement are all working as intended.

1. In the EC2 console (still in **us-west-2**), go to **Security Groups** and select **Create security group**
2. Name it `three-layer-sg`, with description `Validation SG for three-layer VPC`, and attach it to your custom VPC
3. Under **Inbound rules**, add: Type **All traffic**, Source **Custom** `10.20.0.0/16`, Description `Allow all VPC-internal traffic`, then create the group

Launch three instances:

**Front-end instance**
- Name: `frontend-ec2`
- AMI: Amazon Linux (or your preference)
- Instance type: `t3.small`
- Key pair: **Proceed without a key pair** (SSM Session Manager will be used instead)
- Network settings → VPC: your custom VPC; Subnet: `frontend-sn-2a`; Auto-assign Public IP: **Enable**
- Security group: `three-layer-sg`
- Advanced details → IAM instance profile: select the profile containing `EC2SsmAccessRole` in its name (e.g., `stack-SsmEnabledInstanceProfile-8zkcxy9E1RpG`)
- Launch

**Mid-tier instance**
- Name: `midtier-ec2`
- Same AMI/instance type/key pair settings
- Subnet: `midtier-sn-2a`; Auto-assign Public IP: **Disable** (private subnet)
- Security group: `three-layer-sg`
- Same IAM instance profile as above
- Launch

**Data layer instance**
- Name: `data-ec2`
- Same AMI/instance type/key pair settings
- Subnet: `data-sn-2a`; Auto-assign Public IP: **Disable** (no internet path for this layer)
- Security group: `three-layer-sg`
- Same IAM instance profile as above
- Launch

Wait until all three instances show **Running** and pass 2/2 status checks before testing.

**Validation via Session Manager:**
- From `frontend-ec2`: confirm internet reachability (e.g., `ping 8.8.8.8` or `curl https://www.google.com`)
- From `midtier-ec2`: confirm outbound access through the NAT gateway (e.g., `curl https://www.google.com`)
- From `data-ec2`: you should find you **cannot** reach SSM at all — this is expected, since routing and NACL rules block it entirely. That's the intended end state.

> Note: `ping` will fail from the mid-tier instance since ICMP wasn't explicitly permitted in its NACL rules.

## Wrap-Up
Nice work — completing this lab demonstrates several practical, real-world skills:

- Designing a production-style three-layer VPC
- Enforcing clear routing boundaries between layers
- Controlling outbound internet access selectively
- Applying stateless traffic filtering correctly at the subnet level
