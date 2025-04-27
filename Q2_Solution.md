# Verify DNS Resolution
First, check what your system's current DNS is using /etc/resolv.conf, and compare that to Google's public DNS 8.8.8.8.

```bash
cat /etc/resolv.conf
```

```bash
# Use local DNS resolver
dig internal.fawry.com +short

# Use Google DNS (8.8.8.8)
dig @8.8.8.8 internal.fawry.com +short
```

Expected outcomes:

- If local DNS fails but 8.8.8.8 succeeds: local DNS misconfiguration.
- If both fail: either internal DNS is down or the record is missing globally (unlikely for internal systems).

# Diagnose Service Reachability
Once we have an IP address (from dig), test connectivity:

Try connecting to the service:
curl -v http://<resolved-ip>/

Check if the service is listening:

## Check listening ports on the server (run on the server hosting the service)
```bash
sudo ss -tuln | grep ':80\|:443'
```
- Expected Result: curl should return HTTP headers, and ss should show LISTEN on port 80/443.
- Issue Identified: If curl fails but the service is listening, a firewall or routing issue exists.


# Trace the Issue – List Possible Causes

Here are all possible reasons internal.fawry.com might be unreachable:
- Layer	Possible Issue
- DNS	Bad /etc/resolv.conf entry (wrong nameserver)
- DNS	Missing DNS record for internal.example.com
- DNS	Internal DNS server down , DNS poisoning Attack , misconfigured .
- Network	Firewall blocking port 80/443 traffic
- Network	IP routing issue (subnet misconfiguration)
- Network	Server is up but web service not running (Apache/Nginx crash)
- Service	Server listening only on localhost (127.0.0.1) instead of 0.0.0.0
- Service	SSL/TLS misconfiguration (for HTTPS) causing connection failures
- Local	Wrong /etc/hosts entry or bad caching (nscd or systemd-resolved)

# Fixes for Each Potential Cause

Incorrect DNS Server

Confirm: Check /etc/resolv.conf for non-internal DNS servers.

```bash
cat /etc/resolv.conf
```

Fix: Update DNS settings via NetworkManager:
```bash
    nmcli con mod "Your_Connection" ipv4.dns "192.168.1.1"  # Replace with internal DNS
    nmcli con down "Your_Connection"; nmcli con up "Your_Connection"
```
Missing DNS Record

Confirm: Query the authoritative DNS server directly.

```bash
dig @internal-dns-server internal.fawry.com +short
```

Fix: Add the correct A record in the DNS zone file for internal.example.com.

Firewall Blocking Port

Confirm: Check firewall rules on the server and network:
```bash
sudo iptables -L -n -v | grep ':80\|:443'
```

Fix: Allow traffic on port 80/443:
```bash

    sudo firewall-cmd --add-port=80/tcp --permanent  # For firewalld
    sudo firewall-cmd --reload
```

Service Binding to Localhost

Confirm: Check service binding:
```bash
sudo ss -tuln | grep ':80\|:443'  # Should show 0.0.0.0:80, not 127.0.0.1:80
```
Fix: Update web server config (e.g., Apache’s Listen 0.0.0.0:80 or Nginx’s listen 80 default_server).


# Bonus :Configure /etc/hosts to bypass DNS for testing

Add this entry manually:
```bash
sudo nano /etc/hosts
```

Add line: ex: 10.0.0.5 internal.fawry.com 

Test:

ping internal.example.com
curl http://internal.fawry.com