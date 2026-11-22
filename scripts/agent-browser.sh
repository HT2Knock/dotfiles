#!/usr/bin/env bash
set -euo pipefail

# Start the agent browser stack: Xvfb on :99, openbox, Chrome with its own
# profile, and x11vnc on loopback. Linger is on, so the user manager starts the
# target at boot. Run this script by hand only when the stack is down.

systemctl --user start \
  browse-agent-xvfb.service \
  browse-agent-wm.service \
  browse-agent-chrome.service \
  browse-agent-vnc.service
