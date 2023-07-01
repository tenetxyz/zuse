create-instance:
# ami-02238ac43d6385ab3 is the amazon linux 2 ami for intel
# ami-05502a22127df2492 is the amazon linux 2023 ami (not using cause missing core packages)
	aws ec2 run-instances \
	--image-id ami-02238ac43d6385ab3 \
	--count 1 \
	--instance-type m5.xlarge
	--key-name Transistor \
	--block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":32}}]' `# configure the server with 32 Gb of storage` \
	--enclave-options 'Enabled=true'