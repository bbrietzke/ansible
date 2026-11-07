.PHONY: work home docs test image kube-update

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

kube-update:
	$(EXE) $(EXE_OPTIONS) -i inventories/kubernetes/hosts kube_update.yml

openclaw:
	$(EXE) $(EXE_OPTIONS) -i inventories/openclaw/hosts openclaw-agents.yml


