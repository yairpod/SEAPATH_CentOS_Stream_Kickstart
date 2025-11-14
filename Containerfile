# Use the official CentOS Stream 9 image as the base
FROM quay.io/centos/centos:stream9

# Update all packages and clean the cache to keep the image small
# Using 'dnf' as it is the successor to 'yum' in modern CentOS
RUN dnf -y update && \
    dnf clean all

# version comes from the version that seapath tools require
ENV ANSIBLE_VERSION 2.10.7

RUN yum install -y gcc python3 git rsync python3-netaddr python3-six python3-pip
RUN yum install -y vim iputils
RUN pip3 install --upgrade pip; \
    pip3 install "ansible==${ANSIBLE_VERSION}"

# Set the default command to run when the container starts
# This will just open a bash shell
CMD ["/bin/bash"]

