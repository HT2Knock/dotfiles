#!/bin/bash
status=$(fcitx-remote)

case $status in
1)
	echo " EN"
	;;
2)
	echo " VN"
	;;
*)
	echo " OFF"
	;;
esac
