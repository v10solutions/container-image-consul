#
# Container Image Consul
#

.PHONY: container-run-linux
container-run-linux:
	$(BIN_DOCKER) container create \
		--platform "$(PROJ_PLATFORM_OS)/$(PROJ_PLATFORM_ARCH)" \
		--name "consul" \
		-h "consul" \
		--domainname "dc.consul" \
		-u "480" \
		--entrypoint "consul" \
		--net "$(NET_NAME)" \
		-p "8501":"8501" \
		-p "8502":"8502" \
		-p "8600":"8600" \
		-p "8600":"8600"/"udp" \
		--health-interval "10s" \
		--health-timeout "8s" \
		--health-retries "3" \
		--health-cmd "consul-healthcheck \"8501\" \"8502\"" \
		"$(IMG_REG_URL)/$(IMG_REPO):$(IMG_TAG_PFX)-$(PROJ_PLATFORM_OS)-$(PROJ_PLATFORM_ARCH)" \
		agent -config-file "/usr/local/etc/consul/config.hcl"
	$(BIN_FIND) "bin" -mindepth "1" -type "f" -iname "*" -print0 \
	| $(BIN_TAR) -c --numeric-owner --owner "0" --group "0" -f "-" --null -T "-" \
	| $(BIN_DOCKER) container cp "-" "consul":"/usr/local"
	$(BIN_FIND) "etc/consul" -mindepth "1" -type "f" -iname "*" ! -iname "tls-key.pem" -print0 \
	| $(BIN_TAR) -c --numeric-owner --owner "0" --group "0" -f "-" --null -T "-" \
	| $(BIN_DOCKER) container cp "-" "consul":"/usr/local"
	$(BIN_FIND) "etc/consul" -mindepth "1" -type "f" -iname "tls-key.pem" -print0 \
	| $(BIN_TAR) -c --numeric-owner --owner "480" --group "480" --mode "600" -f "-" --null -T "-" \
	| $(BIN_DOCKER) container cp "-" "consul":"/usr/local"
	$(BIN_DOCKER) container start -a "consul" 2>&1 \
	| $(BIN_JQ) -R -r -C --unbuffered ". as \$$line | try fromjson catch \$$line"

.PHONY: container-run
container-run:
	$(MAKE) "container-run-$(PROJ_PLATFORM_OS)"

.PHONY: container-rm
container-rm:
	$(BIN_DOCKER) container rm -f "consul"
