NAME := ghcr.io/yorickpeterse/dotfiles/fedora:main
INSTALLER := fedora-installer

container:
	@podman build -t ${NAME} -f Containerfile .

push: container
	@podman push ${NAME}

image: container
	@mkdir -p build
	@podman run \
		--rm \
		--interactive \
		--tty \
		--privileged \
		--security-opt label=type:unconfined_t \
		--volume ./config.toml:/config.toml:ro \
		--volume ./build:/output \
		--volume /var/lib/containers/storage:/var/lib/containers/storage \
		quay.io/centos-bootc/bootc-image-builder:latest \
		--type raw \
		--use-librepo=True \
		--rootfs btrfs \
		--chown $$(id -u $$(logname)):$$(id -g $$(logname)) \
		${NAME}

installer-container:
	@podman build -t ${INSTALLER} installer

installer: container installer-container
	@mkdir -p build
	@podman run \
		--rm \
		--interactive \
		--tty \
		--privileged \
		--security-opt label=type:unconfined_t \
		--volume ./config.toml:/config.toml:ro \
		--volume ./build:/output \
		--volume /var/lib/containers/storage:/var/lib/containers/storage \
		quay.io/centos-bootc/bootc-image-builder:latest \
		--type bootc-installer \
		--installer-payload-ref ${NAME} \
		--use-librepo=True \
		--rootfs btrfs \
		--chown $$(id -u $$(logname)):$$(id -g $$(logname)) \
		localhost/${INSTALLER}:latest

vm:
	@qemu-system-x86_64 \
		-enable-kvm \
		-cpu host \
		-smp 4 \
		-m 4096 \
		-bios /usr/share/OVMF/OVMF_CODE.fd \
		-net user,hostfwd=tcp::2200-:22 \
		-net nic \
		-nographic \
		-snapshot build/image/disk.raw

ssh:
	@ssh -o "StrictHostKeyChecking no" \
		-o "UserKnownHostsFile=/dev/null" \
		-p 2200 \
		root@localhost

clean:
	@rm -rf build

.PHONY: container push image vm installer-container installer ssh clean
