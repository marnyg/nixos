
rebuild:
	sudo nixos-rebuild switch --flake ".#mardesk"
buildVm:
	nixos-rebuild build-vm --flake ".#mardesk"
	rm ./nixos.qcow2
buildAndRunVm:
	nixos-rebuild build-vm --flake ".#mardesk"
	rm ./nixos.qcow2 || true
	./result/bin/run-nixos-vm
vmSsh:
	nixos-rebuild build-vm --flake ".#mardesk"
	rm ./nixos.qcow2 || true
	sed -i '/:2222/d' ~/.ssh/known_hosts 
	# rsync -e "ssh -p 2222" -r  /etc/nixos/ vm@localhost:~/nixos/
	QEMU_NET_OPTS="hostfwd=tcp::2222-:22" ./result/bin/run-nixos-vm
vagrantInit:
	git clone https://github.com/nix-community/nixbox.git 
	cd nixbox
	packer build --only=virtualbox-iso nixos-x86_64.json
	vagrant box add nixbox64 packer_virtualbox-iso_virtualbox.box
vagrant:
	vagrant up
