.PHONY: work home docs test image

EXE := $(shell which ansible-playbook)
EXE_OPTIONS :=  						# make EXE_OPTIONS=--ask-become-pass updates
DOC := $(shell which mkdocs)			# make EXE_OPTIONS="--ask-become-pass --limit octopi"
UNAME_S := $(shell uname -s)
DEFAULT_GROUP := apartment

$(DOC):
	python3 -m pip install mkdocs

$(EXE):
	brew install ansible

docs: $(DOC)
	$(DOC) gh-deploy

update:
	$(EXE) $(EXE_OPTIONS) -i inventories/$(DEFAULT_GROUP)/hosts updates.yml

default:
	$(EXE) $(EXE_OPTIONS) -i inventories/$(DEFAULT_GROUP)/hosts default.yml
	
reboot:
	$(EXE) $(EXE_OPTIONS) -i inventories/$(DEFAULT_GROUP)/hosts reboot.yml
	
shutdown:
	$(EXE) $(EXE_OPTIONS) -i inventories/$(DEFAULT_GROUP)/hosts shutdown.yml
	
slurm:
	$(EXE) $(EXE_OPTIONS) -i inventories/$(DEFAULT_GROUP)/hosts slurm.yml

kube:
	$(EXE) $(EXE_OPTIONS) -i inventories/$(DEFAULT_GROUP)/hosts local_kube.yml

whatever:
	cp boot/user-data/user-data.rpi /Volumes/system-boot/user-data
	touch /Volumes/system-boot/meta-data
	touch /Volumes/system-boot/ssh
	diskutil eject /Volumes/system-boot

wifi:
	cp boot/network-config /Volumes/system-boot/network-config

octopi:
	cp boot/wpa_supplicant.conf /Volumes/boot/
	cp boot/octopi.txt /Volumes/boot/octopi.txt
	touch /Volumes/boot/ssh

retropie:
	touch /Volumes/boot/ssh && \
	cp boot/wpa_supplicant.conf /Volumes/boot/  && \
	diskutil unmountDisk /dev/disk2
