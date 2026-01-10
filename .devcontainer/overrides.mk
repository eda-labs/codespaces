KPT_RETRY ?= 3

define INSTALL_KPT_PACKAGE
	{	\
		echo -e "--> INSTALL: [\033[1;34m$2\033[0m] - Applying kpt package"									;\
		pushd $1 &>/dev/null || (echo "[ERROR]: Failed to switch cwd to $2" && exit 1)						;\
		if [[ ! -f resourcegroup.yaml ]] || [[ $(KPT_LIVE_INIT_FORCE) -eq 1 ]]; then						 \
			$(KPT) live init --force 2>&1 | $(INDENT_OUT)													;\
		else																								 \
			echo -e "--> INSTALL: [\033[1;34m$2\033[0m] - Resource group found, don't re-init this package"	;\
		fi																									;\
		for attempt in $$(seq 1 $(KPT_RETRY)); do \
			echo -e "--> INSTALL: [\033[1;34m$2\033[0m] - Attempt $$attempt/$(KPT_RETRY)"					;\
			if $(KPT) live apply $(KPT_LIVE_APPLY_ARGS) 2>&1 | $(INDENT_OUT); then \
				break																						;\
			fi																								;\
			if [[ $$attempt -eq $(KPT_RETRY) ]]; then \
				echo -e "--> INSTALL: [\033[1;31m$2\033[0m] - Failed after $(KPT_RETRY) attempts"			;\
				exit 1																						;\
			fi																								;\
			echo -e "--> INSTALL: [\033[1;33m$2\033[0m] - Attempt $$attempt failed, retrying..."			;\
			sleep 2																							;\
		done																								;\
		popd &>/dev/null || (echo "[ERROR]: Failed to switch back from $2" && exit 1)						;\
		echo -e "--> INSTALL: [\033[0;32m$2\033[0m] - Applied and reconciled package"						;\
	}
endef
