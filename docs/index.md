# Setting up my network with Ansible

A set of helpful commands and tools to make setting up and maintaining my network a little easier.

## Setup
Following [Ansible best practices](https://docs.ansible.com/ansible/latest/tips_tricks/sample_setup.html), the project is structured
with an inventories folder that contains the list of hosts that you will want to talk to.  Each inventory contains the
names/ips and usernames of the host machines, along with the various _children_, which are the groups that the playbooks target to decide what software and configuration gets installed where.

The inventories that are present right now:

* `apartment` - the default inventory for the Makefile; has the _servers_, _clients_ and _main_ groups.
* `basement` - the machines in the basement; has the _shutdown_ group.
* `home` - the Raspberry Pis (octopi and retropie).
* `kubernetes` - the Kubernetes cluster; has the _controlplane_ and _workers_ groups.
* `openclaw` - the OpenClaw agent boxes; has the _agents_ group.

All of the Ubuntu machines are expected to be on Ubuntu 26.04 LTS (_resolute_), which is set with `ubuntu_version` in the inventories.

### Personalization
Additional directories can be added to inventories and set up similar to the ones above depending on how you want things to work or look.

## Commands
Everything should be driven through the _Makefile_.  Most targets use the `apartment` inventory unless you tell it otherwise with `DEFAULT_GROUP`.

* `make default` - Install the base packages and users.
* `make update` - Update and upgrade everything.
* `make reboot` - REBOOT!
* `make shutdown` - Shut down the machines in the _shutdown_ group.
* `make slurm` - Install the SLURM controllers and workers.
* `make kube` - Install the base packages and set up the NFS servers and clients.
* `make kube-update` - Rolling update of the Kubernetes nodes, one at a time.
* `make openclaw` - Set up the OpenClaw agent boxes.
* `make docs` - Build the docs and upload them to gh-pages.

Extra options for `ansible-playbook` get passed through with `EXE_OPTIONS`, and a different inventory can be picked with `DEFAULT_GROUP`:

```
make update EXE_OPTIONS=--ask-become-pass
make reboot EXE_OPTIONS="--ask-become-pass --limit eris"
make shutdown DEFAULT_GROUP=basement
```

## Playbook Details
### Default
* `default.yml` - Installs the base packages (avahi, screen, tmux, zsh) and creates the users, pulling their SSH keys from GitHub; also installs the QEMU guest agent on anything in the _qemu_ group.
* `make default`

### Updates
* `updates.yml` - Does an apt update and dist-upgrade on every machine in the inventory, then cleans up and autoremoves old packages.  Does them all at once, and doesn't reboot.
* `make update`

### Reboot
* `reboot.yml` - Well, it reboots the machines; only does two at a time.
* `make reboot`

### Shutdown
* `shutdown.yml` - Shuts down everything in the _shutdown_ group, which only lives in the `basement` inventory.
* `make shutdown DEFAULT_GROUP=basement`

### Slurm
* `slurm.yml` - Installs the SLURM controller on the _controllers_ group and the SLURM workers on the _workers_ group, and writes the shared slurm config to both.
* `make slurm DEFAULT_GROUP=<inventory>`
* None of the inventories have a _controllers_ group right now, and _workers_ only exists in the `kubernetes` inventory, so don't point this at that one unless you want SLURM on your Kubernetes nodes.

### Kube
* `local_kube.yml` - Despite the name, it doesn't install Kubernetes.  It installs the base packages on everything, the QEMU guest agent on the _qemu_ group, sets up an NFS server on the _servers_ group (with _shared_, _data_redis_ and _data_jenkins_ shares) and the NFS client on the _clients_ group.
* `make kube`

### Kube Update
* `kube_update.yml` - Updates the Kubernetes nodes one at a time, workers first and then the control plane.  Each node gets drained (ignoring daemon-sets and deleting empty-dir data), apt updated, full-upgraded and autoremoved, rebooted if anything changed, and then uncordoned whether it rebooted or not.  It waits for the node to come back and for all the pods to settle before moving on to the next one, and stops everything if a node fails.
* `make kube-update` - it always asks for the sudo password, and checks that sudo works on every node before it drains anything.
* kubectl runs on the machine you run `make` from, so its kubeconfig needs to be able to reach the cluster.  The kubernetes packages are kept on hold so they only get upgraded through kubeadm.

### OpenClaw
* `openclaw-agents.yml` - Installs the base packages and users, plus the Prometheus node exporter binary, on the _agents_ group.
* `make openclaw`

## Roles
The roles live in the `roles` folder.  The ones used by the playbooks above are _default_, _qemu_client_, _update_, _nfs_server_, _nfs_client_, _slurm_, _slurmctrl_, _slurm_conf_, _kube_node_update_ and _node_exporter_binary_.

The rest are there to be pulled into a playbook when I need them: _alertmanager_, _apt_cacher_, _apt_cacher_client_, _consul_, _docker_, _elasticsearch_, _java_, _kube_config_, _kubernetes_, _memcached_, _mqtt_, _nginx_, _node_exporter_, _nodejs_, _octopi_camera_, _postgresql_, _print_server_, _prometheus_, _redis_, _samba_server_, _subversion_ and _vault_.
