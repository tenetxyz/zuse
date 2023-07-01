create-instance:
# ami-02238ac43d6385ab3 is the amazon linux 2 ami for intel
# ami-0aaa3bceac094d05d  is the amazon linux 2 ami for arm
# ami-05502a22127df2492 is the amazon linux 2023 ami (not using cause missing core packages)
# ami-009fb1b6af2b866d6 is the july amazon linux 2023 ami
	aws ec2 run-instances \
	--image-id ami-009fb1b6af2b866d6 \
	--count 1 \
	--instance-type c7g.large \
	--key-name Tenet \
	--block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":32}}]' `# configure the server with 32 Gb of storage` \
	--enclave-options 'Enabled=false'

build-services:
	sh build-services.sh
install:
	sh install.sh