#!/usr/bin/env bash
set -u
# Prometheus is intentionally bound to lab loopback. Fetch its API over the
# existing SSH path rather than exposing its unauthenticated HTTP API.
query() {
  ssh -q -o BatchMode=yes -o ConnectTimeout=5 t2knock@t2knock-lab "curl -fsS --max-time 5 --get --data-urlencode 'query=$1' http://127.0.0.1:9090/api/v1/query" 2>/dev/null || return 1
}
extract() {
  python3 -c 'import json,sys; d=json.load(sys.stdin); assert d.get("status")=="success"; [print(json.dumps(x,separators=(",",":"))) for x in d["data"]["result"]]' 2>/dev/null
}

# A target is down continuously across the full five-minute range.
q='min_over_time(up[5m]) == 0 and max_over_time(up[5m]) == 0'
if data=$(query "$q"); then
  while IFS= read -r row; do
    [[ -z "$row" ]] && continue
    python3 -c 'import json,sys; x=json.loads(sys.argv[1]); l=x["metric"]; print("DOWN >5m: %s/%s (%s)"%(l.get("job","?"),l.get("instance","?"),l.get("instance", l.get("__address__","?"))))' "$row"
  done < <(printf '%s' "$data" | extract 2>/dev/null || true)
fi

# Ignore pseudo-filesystems; report every remaining filesystem over 90% full.
q='100 * (1 - node_filesystem_avail_bytes{fstype!~"tmpfs|devtmpfs|overlay|squashfs|proc|sysfs|cgroup2?|fuse.*"} / node_filesystem_size_bytes{fstype!~"tmpfs|devtmpfs|overlay|squashfs|proc|sysfs|cgroup2?|fuse.*"}) > 90'
if data=$(query "$q"); then
  while IFS= read -r row; do
    [[ -z "$row" ]] && continue
    python3 -c 'import json,sys; x=json.loads(sys.argv[1]); l=x["metric"]; print("FILESYSTEM >90%: %s %s (%.1f%%)"%(l.get("instance","?"),l.get("mountpoint","?"),float(x["value"][1])))' "$row"
  done < <(printf '%s' "$data" | extract 2>/dev/null || true)
fi

q='time() - restic_last_snapshot_timestamp_seconds > 93600'
if data=$(query "$q"); then
  while IFS= read -r row; do
    [[ -z "$row" ]] && continue
    python3 -c 'import json,sys; x=json.loads(sys.argv[1]); l=x["metric"]; age=float(x["value"][1])/3600; print("RESTIC SNAPSHOT >26h: %s (%.1f hours old)"%(l.get("instance","?"),age))' "$row"
  done < <(printf '%s' "$data" | extract 2>/dev/null || true)
fi
