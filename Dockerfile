# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:latest

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# START CUSTOM BUILD
RUN apt-get update -qq
RUN apt-get install dnsmasq syslinux nginx -qq -y

RUN mkdir -p /tftpboot/pxelinux.cfg/
RUN mkdir -p /tftpboot/coreos/beta/
RUN mkdir -p /tftpboot/fedora/20/
RUN mkdir -p /tftpboot/centos/7/
RUN mkdir -p /tftpboot/ubuntu/trusty/

RUN cp /usr/lib/syslinux/pxelinux.0 /tftpboot/

# CoreOS 
RUN cd /tftpboot && \
    curl http://beta.release.core-os.net/amd64-usr/current/coreos_production_pxe.vmlinuz > /tftpboot/coreos/beta/vmlinuz && \
    curl http://beta.release.core-os.net/amd64-usr/current/coreos_production_pxe_image.cpio.gz > /tftpboot/coreos/beta/initrd.img

# Fedora 20
RUN cd /tftpboot && \
    curl http://mirror.pnl.gov/fedora/linux/releases/20/Fedora/x86_64/os/images/pxeboot/initrd.img > /tftpboot/fedora/20/initrd.img && \
    curl http://mirror.pnl.gov/fedora/linux/releases/20/Fedora/x86_64/os/images/pxeboot/vmlinuz > /tftpboot/fedora/20/vmlinuz

# CentOS 7
RUN cd /tftpboot && \
    curl http://mirror.anl.gov/pub/centos/7/os/x86_64/images/pxeboot/initrd.img > /tftpboot/centos/7/initrd.img && \
    curl http://mirror.anl.gov/pub/centos/7/os/x86_64/images/pxeboot/vmlinuz > /tftpboot/centos/7/vmlinuz

# Ubuntu 14.04
RUN cd /tftpboot && \
    curl http://mirror.pnl.gov/ubuntu/dists/trusty/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/initrd.gz > /tftpboot/ubuntu/trusty/initrd.gz && \
    curl http://mirror.pnl.gov/ubuntu/dists/trusty/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/linux  > /tftpboot/ubuntu/trusty/linux

RUN mkdir /etc/service/dnsmasq

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

EXPOSE 67 53 80

RUN mkdir /etc/service/nginx
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

ADD confs/dnsmasq.hosts /etc/dnsmasq.hosts
ADD confs/default /tftpboot/pxelinux.cfg/default
ADD confs/dnsmasq.conf /etc/dnsmasq.conf
ADD confs/nginx.default /etc/nginx/sites-available/default
ADD scripts/dnsmasq.sh /etc/service/dnsmasq/run
ADD scripts/nginx.sh /etc/service/nginx/run
ADD http_files /var/www

# END CUSTOM BUILD
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
