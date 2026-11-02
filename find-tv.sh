#!/usr/bin/env bash
# Finds Sony Bravia TVs on the LAN via SSDP and saves the first one to state/tv.conf
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; mkdir -p "$HERE/state"
python3 - "$HERE/state/tv.conf" <<'PY'
import socket, re, sys, urllib.request
msg = b'M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: "ssdp:discover"\r\nMX: 2\r\nST: ssdp:all\r\n\r\n'
# send from the default-route interface (laptops with Docker/VPN have several)
probe = socket.socket(socket.AF_INET, socket.SOCK_DGRAM); probe.connect(("8.8.8.8", 80)); local_ip = probe.getsockname()[0]; probe.close()
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM); s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF, socket.inet_aton(local_ip)); s.bind((local_ip, 0)); s.settimeout(4)
s.sendto(msg, ("239.255.255.250", 1900)); s.sendto(msg, ("239.255.255.250", 1900))
locs = {}   # ip -> set(LOCATION urls)
try:
    while True:
        data, addr = s.recvfrom(4096); t = data.decode(errors="ignore")
        m = re.search(r"LOCATION:\s*(http://\S+)", t, re.I)
        locs.setdefault(addr[0], set()).add(m.group(1) if m else "")
        if "sony" in t.lower(): locs[addr[0]].add("sony-hint")
except socket.timeout: pass
found = {}
for ip, urls in locs.items():
    name = model = None
    for u in sorted(urls):
        if u == "sony-hint": found.setdefault(ip, ("?", "?")); continue
        if not u: continue
        try: x = urllib.request.urlopen(u, timeout=3).read().decode(errors="ignore")
        except Exception: continue
        if "sony" in x.lower():
            n = re.search(r"<friendlyName>([^<]*)", x); mo = re.search(r"<modelName>([^<]*)", x)
            name = name or (n.group(1) if n else None); model = model or (mo.group(1) if mo else None)
            found[ip] = (model or "?", name or "?")
if not found:
    print("No Sony TV answered. Make sure the TV is on and on the same Wi-Fi, then: export TV_IP=<ip from Settings > Network > Status>"); sys.exit(1)
for ip, (model, name) in found.items(): print(f"{ip}  {model}  ({name})")
first = next(iter(found)); open(sys.argv[1], "w").write(first); print(f"Saved {first} to state/tv.conf")
PY
