clean:
	rm -f confs/*
	rm -f http_files/*

confs/%:
	./bin/render $(@F) $(CONTEXT) > $@

http_files/%: 
	./bin/render $(@F) $(CONTEXT) > $@

files: confs/dnsmasq.conf confs/dnsmasq.hosts confs/nginx.default confs/resolv.dnsmasq confs/default

https: http_files/centos.cfg

include environments/*.mk

.PHONY: clean
