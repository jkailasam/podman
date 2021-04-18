FROM centos

RUN useradd build; dnf -y module enable container-tools:rhel8; dnf -y update; dnf -y reinstall shadow-utils; dnf -y install podman fuse-overlayfs /etc/containers/storage.conf; rm -rf /var/cache /var/log/dnf* /var/log/yum.*

# Adjust storage.conf to enable Fuse storage.
RUN sed -i -e 's|^#mount_program|mount_program|g' -e '/additionalimage.*/a "/var/lib/shared",' /etc/containers/storage.conf
RUN mkdir -p /var/lib/shared/overlay-images /var/lib/shared/overlay-layers; touch /var/lib/shared/overlay-images/images.lock; touch /var/lib/shared/overlay-layers/layers.lock

# Use cgroups cgroup_manager by default (#1908567)
RUN sed -i -e '/^cgroup_manager.*/d' -e '/\#\ cgroup_manager\ =/a cgroup_manager = "cgroupfs"' /usr/share/containers/containers.conf

# workaround for rhbz#1918554
RUN sed -i -e 's|"/var/lib/shared",|#"/var/lib/shared",|' /etc/containers/storage.conf
ENV STORAGE_DRIVER=vfs

# Set up environment variables to note that this is
# not starting with usernamespace and default to
# isolate the filesystem with chroot.
ENV _BUILDAH_STARTED_IN_USERNS="" BUILDAH_ISOLATION=chroot
