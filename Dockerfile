FROM centos:7

ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Without this, init won't start the enabled services and exec'ing and starting
# them reports "Failed to get D-Bus connection: Operation not permitted".
VOLUME /run /run/lock /tmp

# Install anything. The service you want to start must be a SystemD service.

CMD ["/usr/sbin/init"]

# Now is where the fun begins

RUN rpm -Uvh http://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm

# yum installs
RUN yum install yum-utils nano man htop puppet puppetserver facter -y

# Change min max mem to 512m for puppetserver
RUN sed -i 's/2g/512m/g' /etc/sysconfig/puppetserver

# Adding following lines to puppet config
RUN echo -e "\n[main]\ncertname = puppet.docker\nserver = puppet.docker\n[agent]\nserver = puppet.docker" >> /etc/puppetlabs/puppet/puppet.conf
# Define hostname for network
RUN echo -e "NETWORKING=yes\nHOSTNAME=puppet.docker" >> /etc/sysconfig/network
# END Follow post docker-up steps in main README.md
