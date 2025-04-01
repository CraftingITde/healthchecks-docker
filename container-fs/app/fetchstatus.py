#!/usr/bin/env python

import os
from urllib.parse import urlparse
from urllib.request import Request, urlopen

# Lese SITE_ROOT aus der Umgebung
SITE_ROOT = os.getenv("SITE_ROOT", "http://localhost:8000")

parsed_site_root = urlparse(SITE_ROOT.strip("/"))
url = f"{parsed_site_root}/api/v3/status/"
headers = {"Host": parsed_site_root.netloc}

try:
    with urlopen(Request(url, headers=headers)) as response:
        assert response.status == 200
    print("Status OK")
    exit(0)
except Exception as e:
    print(f"Health check failed: {e}")
    exit(1)