#!/bin/bash

# Define critical folder paths
CRITICAL_FOLDERS=("/var/log" "/var/www" "/home/user")

# Define the threshold for folder usage (85%)
FOLDER_THRESHOLD=85

# Define the threshold for CPU usage (90%)
CPU_THRESHOLD=90

# Define the threshold for the number of users (100)
USER_THRESHOLD=100

# Function to check folder usage
check_folder_usage() {
  for folder in "${CRITICAL_FOLDERS[@]}"; do
    usage=$(df -h "$folder" | awk 'NR==2 { print $5 }' | cut -d'%' -f1)
    if [ "$usage" -ge "$FOLDER_THRESHOLD" ]; then
      echo "Warning: Folder $folder usage is $usage%."
    fi
  done
}

# Function to check CPU usage
check_cpu_usage() {
  cpu_usage=$(top -bn1 | awk '/^%Cpu/ {print $2}' | cut -d. -f1)
  if [ "$cpu_usage" -ge "$CPU_THRESHOLD" ]; then
    echo "Warning: CPU usage is $cpu_usage%."
  fi
}

# Function to check the number of users
check_user_count() {
  user_count=$(cat /etc/passwd | wc -l)
  if [ "$user_count" -gt "$USER_THRESHOLD" ]; then
    echo "Warning: Number of users on the system is $user_count, exceeding the threshold of $USER_THRESHOLD."
  fi
}

# Main function
main() {
  check_folder_usage
  check_cpu_usage
  check_user_count
}

# Run the script
main
