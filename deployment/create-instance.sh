#!/bin/sh


# ami-02238ac43d6385ab3 is the amazon linux 2 ami for intel
# ami-0aaa3bceac094d05d  is the amazon linux 2 ami for arm
# ami-05502a22127df2492 is the amazon linux 2023 ami (not using cause missing core packages)
# ami-009fb1b6af2b866d6 is the july amazon linux 2023 ami

# my prompt to bing: how do I launch a new instance using aws ec2 run-instances then print the resulting instance url to the terminal in 1 command?
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-009fb1b6af2b866d6 \
    --count 1 \
    --instance-type c7g.large \
    --key-name Tenet \
    --block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":32}}]' `# configure the server with 32 Gb of storage` \
    --enclave-options 'Enabled=false' \
    --query 'Instances[0].InstanceId' --output text) \
&& sleep 5 && PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[].Instances[].PublicIpAddress' --output text) \
&& host "$PUBLIC_IP" | awk '{print "export SERVER_HOST=" substr($5, 1, length($5)-1)}' | tee server_url.rc

source server_url.rc

# write the prod host to the client prod env file so when we build the client, it will point to the server
sed -i '' '/VITE_PROD_HOST/d' ../packages/client/.env.production
echo "VITE_PROD_HOST=$SERVER_HOST" >> ../packages/client/.env.production


# echo the command for us to ssh into the server
echo ssh -i "~/.ssh/Tenet.pem" "ec2-user@$SERVER_HOST"
