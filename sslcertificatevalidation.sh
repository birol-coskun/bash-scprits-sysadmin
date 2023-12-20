#!/bin/bash

# Set the target IP address (replace with the desired IP address)
target_ip="please put your ip adress"

get_certificate_info() {
    local ip_address="$1"
    local port="$2"

    # Use the OpenSSL command to retrieve certificate information
    local command="openssl s_client -connect ${ip_address}:${port} -showcerts </dev/null"
    local result=$(eval "$command")

    # Extract certificate information
    local cert_start=$(echo "$result" | grep -b -m 1 "-----BEGIN CERTIFICATE-----" | cut -d: -f1)
    local cert_end=$(echo "$result" | grep -b -m 1 "-----END CERTIFICATE-----" | cut -d: -f1)
    local certificate=$(echo "$result" | awk -v start="$cert_start" -v end="$cert_end" 'NR > start && NR <= end {print}')

    # Use the OpenSSL command to parse certificate information
    local openssl_command="openssl x509 -noout -enddate"
    local expiration_date_str=$(echo "$certificate" | openssl x509 -noout -enddate | cut -d= -f2 | xargs)

    # Get the expiration date
    local expiration_date=$(date -d "${expiration_date_str}" "+%Y-%m-%d %H:%M:%S")

    echo "${expiration_date}"
}

main() {
    # Set the target port
    local target_port=443

    # Get certificate information
    local expiration_date=$(get_certificate_info "${target_ip}" "${target_port}")

    if [ -n "${expiration_date}" ]; then
        # Check the expiration date
        local current_date=$(date "+%Y-%m-%d %H:%M:%S")
        local days_left=$(( ($(date -d "${expiration_date}" "+%s") - $(date -d "${current_date}" "+%s")) / 86400 ))

        if [ "${days_left}" -gt 0 ]; then
            echo "The certificate will expire in ${days_left} days."
        else
            echo "The certificate has expired."
        fi
    fi
}

# Call the main function
main
