---
title: "study notes - azure networking fundamentals"
date: 2025-08-10T07:45:00+01:00
draft: false
tags:
    - cloud
    - azure
    - networking
---

### **Context**
I’ve been taking a few courses to solidify my networking fundamentals knowledge.
For anyone interested, I took 
- [Networking Fundamentals](https://www.coursera.org/learn/akamai-networking/) to learn the primitives
- Skimmed through [Network Systems Foundation](https://www.coursera.org/learn/network-systems-foundations/home/welcome). This course goes a bit deeper into the different TCP layers 
- and, [Azure Networking Fundamentals](https://www.coursera.org/learn/azure-networking-fundamentals/home/welcome) made the concepts I learnt above come to life

The main aim was to understand the **patterns available in (Azure) networking** — especially how they apply to VNets and VMs — and be able to recall them quickly.  

---


### VPN Connections

**Site-to-Site (S2S)**  
```

🏢 On-Premises Network
   (Local LAN + Router/VPN device)
           |
           | 🌐 Public Internet
           v
🔐 VPN Tunnel (IPsec/IKE)
           |
           v
🌐 Azure Public IP of Virtual Network Gateway
           |
           v
🛠️ Azure Virtual Network Gateway
           |
           v
🕸️ Azure Virtual Network (VNet)
   ├── 📦 Subnet 1 (App Servers)
   ├── 📦 Subnet 2 (DB Servers)
   └── 📦 Subnet 3 (Management)


```
- Connects entire networks (on-prem ↔ Azure, or VNet ↔ VNet)  
- Requires public IPs of both sites  
- Traffic is encrypted and tunneled via VPN Gateway  
- VPN Gateway works with AAA (Authentication, Authorization, Accounting)  

**Point-to-Site (P2S)**  
```

💻 Remote Client Device
   (Laptop / PC with VPN client)
           |
           | 🌐 Public Internet
           v
🔐 VPN Tunnel (SSL / SSTP / OpenVPN / IKEv2)
           |
           v
🌐 Public IP of Azure Virtual Network Gateway
           |
           v
🛠️ Azure Virtual Network Gateway
           |
           v
🕸️ Azure Virtual Network (VNet)
   ├── 📦 Subnet 1 (App Servers)
   ├── 📦 Subnet 2 (DB Servers)
   └── 📦 Subnet 3 (Management)


```
- Connects a single client device to Azure VNet  
- Uses certificates or Azure AD authentication
<br>

--- 

### VNet Connectivity

**Within a VNet**
- All subnets can talk to each other by default  
- Network Security Groups (NSGs) or User defined routes (UDRs) can restrict traffic  

**Between VNets (Peering)**  

- Regional Peering = same region  
- Global Peering = different regions  
- No transitive routing by default

```

🏢 On-Premises Network
           ⇅
           🌐 Public Internet
           ⇅
🛠️ VPN Gateway (in Hub VNet)
           ⇅
🕸️ Hub VNet
   ├── 📦 Shared Services
   ├── 🌉 Gateway Transit Enabled
   │
   ├── 🔀 VNet Peering to Spoke A (Use Remote Gateway: Yes)
   │       ⇅
   │       📦 Spoke VNet A Resources
   │
   └── 🔀 VNet Peering to Spoke B (Use Remote Gateway: Yes)
           ⇅
           📦 Spoke VNet B Resources

```
- Share one VPN/ExpressRoute gateway across multiple VNets  
- Works both ways: spoke ↔ on-prem ↔ spoke

**Service Chaining**

```

[VNet A] → [Firewall/NVA] → [VNet B]

```
- Use UDRs to send traffic through appliances  
- Appliances can provide firewalling, authentication, packet inspection  
- Common examples: Azure Firewall, FortiGate, Palo Alto  


### Summary of key patterns

1. **Hub-and-Spoke + Gateway Transit** → Centralized connectivity (instead of multiple VPN gateways per VNet)  
2. **Service Chaining** → Route traffic through security appliances between VNet connections
3. **S2S VPN** → Secure network-to-network connection  
4. **P2S VPN** → Secure single-device connection  
5. **VNet Peering** → Direct Azure-to-Azure communication between VNets


### Azure Load Balancing

| Service             | Layer | Main Role                       | Load Balancing Type                                                                                                                     |
| ------------------- |-----| ------------------------------- |-----------------------------------------------------------------------------------------------------------------------------------------|
| **Azure CDN**       | L7  | Static content delivery         | Edge caching only                                                                                                                       |
| **Traffic Manager** | DNS | Global routing                  | Endpoint selection before connection (during DNS resolution). Subsequent calls are served from DNS cache on client side till TTL expire |
| **Load Balancer**   | L4  | High-speed traffic distribution | TCP/UDP-based                                                                                                                           |
| **App Gateway**     | L7  | Intelligent routing + WAF       | HTTP(S)-aware balancing                                                                                                                 |



### Azure Network Security

| **Component** | **What it is** | **When to Use** | **Example** |
|---------------|---------------|-----------------|-------------|
| **Network Security Groups (NSGs)** | Virtual firewalls at the subnet or NIC level that filter traffic based on source/destination IP, port, and protocol. | When you need to **allow/deny specific traffic** between Azure resources or from the internet, especially for basic inbound/outbound control at the VNet/subnet/VM level. | Allow inbound HTTP/HTTPS from internet to web tier; block all inbound to database tier except from app tier. |
| **Azure Firewall** | Fully managed, stateful firewall service with centralized policy control, application-level filtering (FQDNs, domains), and logging. | When you need **centralized security** across multiple VNets, advanced traffic inspection, or rules that go beyond IP/port (e.g., filter by FQDN). Ideal for hub-and-spoke architectures. | Control internet egress from all VNets so only approved domains (e.g., `*.microsoft.com`) are allowed. |
| **Application Security Groups (ASGs)** | Logical groupings of VMs that can be used in NSG rules instead of individual IP addresses. | When you want to **simplify and scale NSG rules** by grouping servers (e.g., “WebServers”) so security policies follow workloads as they scale or change IPs. | Create ASGs for **FrontEnd**, **BackEnd**, and **DB** tiers. NSG rules: allow FrontEnd → BackEnd (TCP 443), BackEnd → DB (TCP 1433), and deny all other cross-tier traffic. |

