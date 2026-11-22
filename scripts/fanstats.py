#!/usr/bin/env python3
"""Summarize the fan-watch log: fan RPM and temperature per hour, and the
night window (23:00-02:00) per day."""

import collections
import datetime
import pathlib
import re
import sys

LOG = pathlib.Path.home() / ".local/state/fan-watch/fan.log"
LINE = re.compile(
    r"^(\S+) fan=(\d+) pwm=(\d+) cpu=(-?\d+) ambient=(-?\d+) gpu=(-?\d+) load=([\d.]+)"
)


def read(path):
    rows = []
    for line in path.read_text().splitlines():
        match = LINE.match(line.strip())
        if not match:
            continue
        stamp = match.group(1).replace("+0700", "+07:00")
        rows.append(
            (
                datetime.datetime.fromisoformat(stamp),
                int(match.group(2)),
                int(match.group(4)),
            )
        )
    return rows


def hourly(rows):
    buckets = collections.defaultdict(list)
    for stamp, fan, cpu in rows:
        buckets[stamp.strftime("%m-%d %H")].append((fan, cpu))
    print("%-9s%4s%8s%8s%8s%8s" % ("hour", "n", "avgfan", "maxfan", "avgcpu", "maxcpu"))
    for key in sorted(buckets):
        values = buckets[key]
        fans = [value[0] for value in values]
        cpus = [value[1] for value in values]
        print(
            "%-9s%4d%8d%8d%8d%8d"
            % (
                key,
                len(values),
                sum(fans) // len(fans),
                max(fans),
                sum(cpus) // len(cpus),
                max(cpus),
            )
        )


def nights(rows):
    by_night = collections.defaultdict(list)
    for stamp, fan, cpu in rows:
        night = (stamp - datetime.timedelta(hours=6)).date()
        by_night[str(night)].append((stamp, fan, cpu))
    print()
    print("%-12s%10s%10s%10s%10s" % ("night", "maxfan", "t@maxfan", "avgcpu", "maxcpu"))
    for day in sorted(by_night):
        window = [row for row in by_night[day] if 23 <= row[0].hour or row[0].hour < 2]
        if not window:
            continue
        peak = max(window, key=lambda row: row[1])
        cpus = [row[2] for row in window]
        print(
            "%-12s%10d%10s%10d%10d"
            % (day, peak[1], peak[0].strftime("%H:%M:%S"), sum(cpus) // len(cpus), max(cpus))
        )


def main():
    path = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else LOG
    rows = read(path)
    if not rows:
        raise SystemExit("no samples in %s" % path)
    print("samples %d from %s to %s" % (len(rows), rows[0][0], rows[-1][0]))
    hourly(rows)
    nights(rows)


if __name__ == "__main__":
    main()
