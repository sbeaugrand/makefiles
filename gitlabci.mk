# ---------------------------------------------------------------------------- #
## \file gitlabci.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
HDIR ?= ../hosts
HOST ?= lubuntu
BHOST ?= lubuntu
ifeq (,$(findstring $(MAKECMDGOALS),\
 rbuild\
 rtest\
 rpackage\
 rinstall\
 rxbuild\
 rxpackage\
 ))
 -include $(HDIR)/$(HOST)/host.mk
else
 -include $(HDIR)/$(BHOST)/host.mk
endif

PROJECT ?= $(shell basename `readlink -f .`)
IMAGE ?= ubuntu:23.04
BUILD ?= Debug
ifeq ($(BUILD),Release)
 gitlabciyml = gitlab-ci-release.yml
else
 gitlabciyml = gitlab-ci.yml
endif
NOCLEAN ?= 0
URI ?= exemple@ip
SSH ?= vagrant ssh -c
ifneq ($(JOIN),)
 SCP ?= scp $(JOIN)
else
 SCP ?= scp
endif
USERPATH ?= /vagrant/.vagrant
ifneq ($(XC),)
 OPTS += -e XC=$(XC)
 REINSTALL ?= xbpd
else
 REINSTALL ?= rbpd
endif
ifneq ($(XCVER),)
 OPTS += -e XCVER=$(XCVER)
endif
ifneq ($(XCDIR),)
 OPTS += -e XCDIR=$(XCDIR)
endif
ifneq ($(SUDOPASS),)
 OPTS += -e SUDOPASS=$(SUDOPASS)
endif

ifeq ($(CMAKE),)
 NCMAKE = cmake .. -DCMAKE_BUILD_TYPE=$(BUILD)
else ifeq ($(CMAKE),qmake)
 NCMAKE = qmake ../$(PROJECT).pro
else
 NCMAKE = $(CMAKE)
endif

gitlabci = ~/.local/bin/gitlabci-local\
 -e HOST=$(HOST)\
 -e BHOST=$(BHOST)\
 -e IMAGE=$(IMAGE)\
 -e BUILD=$(BUILD)\
 -e NOCLEAN=$(NOCLEAN)\
 -e CMAKE="$(NCMAKE)"\
 -e URI=$(URI)\
 -e SSH="$(SSH)"\
 -e SCP="$(SCP)"\
 -e USERPATH=$(USERPATH)\
 $(OPTS)\
 -c $(gitlabciyml)
propath = $(shell basename `readlink -f .`)

.SUFFIXES:

.PHONY: \
build test package install rbuild rtest rpackage rinstall rdeploy stest
build test package install rbuild rtest rpackage rinstall rdeploy stest:
	@$(gitlabci) -H -R -p $@

.PHONY: \
xbuild xpackage xinstall xdeploy xtest rxbuild rxpackage rxdeploy rxinstall
xbuild xpackage xinstall xdeploy xtest rxbuild rxpackage rxdeploy rxinstall:
	@$(gitlabci) -H -R -p $@

.PHONY: deploy
deploy:
	@$(gitlabci) -E docker $@

test%:
	@$(gitlabci) -H -R $@

.PHONY: pipeline
pipeline:
	@$(MAKE) --no-print-directory test
	@$(MAKE) --no-print-directory rbuild
	@$(MAKE) --no-print-directory rtest
	@$(MAKE) --no-print-directory rpackage
	@$(MAKE) --no-print-directory rdeploy
	@$(MAKE) --no-print-directory stest

.PHONY: xpipeline
xpipeline: test xbuild xpackage xdeploy xtest

.PHONY: rbpd
rbpd:
	@$(MAKE) --no-print-directory rbuild
	@$(MAKE) --no-print-directory rpackage
	@$(MAKE) --no-print-directory rdeploy

.PHONY: xbpd
xbpd: xbuild xpackage xdeploy

.PHONY: reinstall
reinstall:
	@$(MAKE) --no-print-directory $(REINSTALL) NOCLEAN=1

.PHONY: xbit
xbit: xbuild xinstall xtest

.PHONY: rxbit
rxbit:
	@$(MAKE) --no-print-directory rxbuild
	@$(MAKE) --no-print-directory rxinstall
	@$(MAKE) --no-print-directory restart
	@$(MAKE) --no-print-directory stest

.PHONY: start stop restart
start stop restart:
	@$(SSH) -q -t "echo $(SUDOPASS) |\
	 sudo -S -p 'sudo systemctl $@ $(PROJECT)' true && echo &&\
	 sudo systemctl $@ $(PROJECT)"

.PHONY: tar
tar:
	@cd .. && tar cvzf $(propath).tgz\
	 --exclude=*~\
	 --exclude=.*.swp\
	 --exclude=build\
	 makefiles/*.*\
	 $(propath)
