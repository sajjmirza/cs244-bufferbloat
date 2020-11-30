#!/bin/bash
set -e

# Note: Mininet must be run as root.  So invoke this shell script
# using sudo.

time=60
bwnet=10
# TODO: If you want the RTT to be 4ms what should the delay on each
# link be?  Set this value correctly. 1 + 1 + 1 + 1 = 4: Therefore delay = 1
delay=1

iperf_port=5001

modprobe tcp_probe
# make sure we don't use a cached cwnd
sysctl -w net.ipv4.tcp_no_metrics_save=1

for qsize in 5 20 100; do
    dir=bb-q$qsize

    python bufferbloat.py --dir=$dir --time=$time --bw-net=$bwnet --delay=$delay --maxq=$qsize

    # TODO: Ensure the input file names match the ones you use in
    # bufferbloat.py script.  Also ensure the plot file names match
    # the required naming convsention when submitting your tarball.
    python plot_tcpprobe.py -f $dir/cwnd.txt -o $dir/cwnd-$qsize.png -p $iperf_port
    python plot_queue.py -f $dir/q.txt -o $dir/q-$qsize.png
    python plot_ping.py -f $dir/ping.txt -o $dir/rtt-$qsize.png
    python plot_ping.py -f $dir/download.txt -o $dir/download-$qsize.png -d down
done
