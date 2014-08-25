Docker PXE Server Container
===========================

This project is for generating a PXE server for different environments. It uses 
Jinja2 templates and context files to generate the specific configuration and 
kickstart files for the pxe server. The image is build with most of the popular
pxe targets iamges built in.

Dependencies
------------

Besides docker, there are a few python dependencies. You can install them using 
pip and the requirements.txt file.

    pip install -r requirements.txt

Example
-------

There’s an example context included. To generate the associated files, you can 
execute 

    make pao19-centos

You’ll probably see something like

    rm -f confs/*
    rm -f http_files/*
    ./bin/render dnsmasq.conf pao19-centos > confs/dnsmasq.conf
    ./bin/render dnsmasq.hosts pao19-centos > confs/dnsmasq.hosts
    ./bin/render nginx.default pao19-centos > confs/nginx.default
    ./bin/render resolv.dnsmasq pao19-centos > confs/resolv.dnsmasq
    ./bin/render default pao19-centos > confs/default
    ./bin/render centos.cfg pao19-centos > http_files/centos.cfg


Adding New Environments
-----------------------

To add a new environment, you have to edit the Makefile until I figure out how 
to fully generalize the targets. For example, if we were adding a new 
environment called ‘docker-cluster’, we’d 

1. Create a new context in contexts/docker-cluster.yml
2. Create a new make target in environments/. If making one for an environment 
   called ‘docker-cluster’, you might create a file called 
   environments/docker-cluster.mk that looks like

    docker-cluster: CONTEXT=docker-cluster
    docker-cluster: clean files cfg_files


Adding New Template Targets
---------------------------

Currently, there are two types of templates. Ones for files served over 
http to clients and ones that are copied over to the container. Both of the 
kinds of templates are placed in the ‘templates’ directory. So step one is just 
creating the template itself and placing it there.

Step two is creating the target in the Makefile. For new http served templates,
add them to the https: target. For others, add to the files target. Should be 
pretty obvious from looking at the current Makefile.

Building and Running
--------------------

Once you’ve generated the configuration files with 

    make <environment_name>

The container can be built. For example,

    docker -t jameskyle/pxe-server .

The server runs as the dnsmasq user and needs access to the hosts network. The 
following commmand provides those capabilities.

    docker run -d --net=host --privileged=true --name pxe-server \
    jameskyle/pxe-server /sbin/my_init

If you want to debug the server, you can run a bash shell

    docker run --net=host --privileged=true -t --name pxe-server -i \
    jameskyle/pxe-server /sbin/my_init -- /bin/bash
