#!/bin/bash

# Set dates
create_date=$(date +"%d-%m-%Y");
delete_date=$(date +"%d-%m-%Y" -d "7 day ago");

# Get lists of snapshots and disks
snapshots=($(yc compute snapshot list --format yaml | awk '{ split($0, a, ": "); if (a[1] == "  name") print a[2]}'))
declare -p snapshots

disks=($(yc compute disk list --format yaml | awk '{ split($0, a, ": "); if (a[1] == "- id") print a[2]}'))
declare -p disks

# Check if there's snapshots to delete and delete them
for snapshot in ${snapshots[@]}; do
  check_date=$(echo $snapshots | awk '{sub(/-/," ")}1' | awk '{print $2}')
  if [[ ${check_date} == ${delete_date} ]]; then
    yc compute snapshot delete $snapshot
  fi
done

# Create new snapshots
for disk in ${disks[@]}; do
  yc compute snapshot create --name "${disk}-${create_date}" --disk-id ${disk}
done
