#!/bin/bash

INPUT_FILE="security-group.json"

SECURITY_GROUP=$(cat $INPUT_FILE)

GROUP_NAME=$(echo $SECURITY_GROUP | jq -r '.SecurityGroups[0].GroupName')
DESCRIPTION=$(echo $SECURITY_GROUP | jq -r '.SecurityGroups[0].Description')
VPC_ID=$(echo $SECURITY_GROUP | jq -r '.SecurityGroups[0].VpcId // empty')
IP_PERMISSIONS=$(echo $SECURITY_GROUP | jq -r '.SecurityGroups[0].IpPermissions')
IP_PERMISSIONS_EGRESS=$(echo $SECURITY_GROUP | jq -r '.SecurityGroups[0].IpPermissionsEgress')

if [ ! -z "$VPC_ID" ]; then
    echo "The original security group was in VPC $VPC_ID."
    echo -n "Please provide a VPC ID to use in this account (default is to use the same VPC ID): "
    read NEW_VPC_ID
    NEW_VPC_ID=${NEW_VPC_ID:-$VPC_ID}
else
    echo -n "Please provide a VPC ID to use in this account: "
    read NEW_VPC_ID
fi

GROUP_ID=$(aws ec2 create-security-group --group-name "$GROUP_NAME" --description "$DESCRIPTION" --vpc-id "$NEW_VPC_ID" --query 'GroupId' --output text 2>&1)

if [[ $? -ne 0 ]]; then
    echo "Failed to create security group: $GROUP_ID"
    exit 1
else
    echo "Created security group $GROUP_NAME with ID $GROUP_ID"
fi

if [ "$IP_PERMISSIONS" != "[]" ]; then
    INGRESS_RESULT=$(aws ec2 authorize-security-group-ingress --group-id "$GROUP_ID" --ip-permissions "$IP_PERMISSIONS" 2>&1)
    if [[ $? -eq 0 ]]; then
        echo "Ingress rules added to $GROUP_NAME"
    else
        if [[ $INGRESS_RESULT == *"InvalidPermission.Duplicate"* ]]; then
            echo "Ingress rule already exists for $GROUP_NAME"
        else
            echo "Failed to add ingress rules to $GROUP_NAME: $INGRESS_RESULT"
            exit 1
        fi
    fi
fi

if [ "$IP_PERMISSIONS_EGRESS" != "[]" ]; then
    EGRESS_RESULT=$(aws ec2 authorize-security-group-egress --group-id "$GROUP_ID" --ip-permissions "$IP_PERMISSIONS_EGRESS" 2>&1)
    if [[ $? -eq 0 ]]; then
        echo "Egress rules added to $GROUP_NAME"
    else
        if [[ $EGRESS_RESULT == *"InvalidPermission.Duplicate"* ]]; then
            echo "Egress rule already exists for $GROUP_NAME"
        else
            echo "Failed to add egress rules to $GROUP_NAME: $EGRESS_RESULT"
            exit 1
        fi
    fi
fi

echo "Security group $GROUP_NAME with ID $GROUP_ID has been configured successfully."
exit 0