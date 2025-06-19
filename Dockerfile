FROM fedora:42

LABEL maintainer="HP van Braam <hp@tmm.cx>"
LABEL description="Certum Code Signing in the Cloud container for Linux CI/CD"
LABEL version="1.0.0"
LABEL org.opencontainers.image.title="Certum Code Signing Container"
LABEL org.opencontainers.image.description="Container for using Certum Code Signing in the Cloud with Linux"
LABEL org.opencontainers.image.url="https://github.com/hpvb/certum-container"
LABEL org.opencontainers.image.source="https://github.com/hpvb/certum-container"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.vendor="HP van Braam"

WORKDIR /root

# For Simply Sign Desktop
ENV	LIBGL_ALWAYS_INDIRECT=1
ENV	USER=root
ENV	DISPLAY=:99

# Install required packages for VNC, X11, and p11-kit
RUN 	dnf -y install --setopt=install_weak_deps=False pcsc-lite-libs libglvnd-glx tigervnc-server-minimal stalonetray blackbox libXcomposite libXi libICE libSM pulseaudio-libs-glib2 supervisor p11-kit-server libxslt && \
	dnf clean all

# Install SimplySignDesktop
RUN	curl -O https://files.certum.eu/software/SimplySignDesktop/Linux-RedHat/2.9.10-9.2.14.0/SimplySignDesktop-2.9.10-9.2.14.0-x86_64-prod-centos.bin && \
	echo "1bb72568f27ceb46aaa2906d3347dd49c72ea4795eded79f7b3ecb18b6379947  SimplySignDesktop-2.9.10-9.2.14.0-x86_64-prod-centos.bin" | sha256sum -c && \
	yes yes | sh SimplySignDesktop-2.9.10-9.2.14.0-x86_64-prod-centos.bin --target /root/certum && \
	rm -f SimplySignDesktop-2.9.10-9.2.14.0-x86_64-prod-centos.bin && \
	mv /root/certum/SSD-2.9.10-dist /opt/SimplySignDesktop/ && \
	rm -rf certum && \
	cp /opt/SimplySignDesktop/SimplySignDesktop.xml /root && \
	sed -i '2i sleep 2 # Give stalonetray some time to start.' /opt/SimplySignDesktop/SimplySignDesktop_start

COPY	files /
RUN	chmod +x /root/entrypoint.sh

VOLUME  /run/p11-kit
EXPOSE  5900

ENTRYPOINT /root/entrypoint.sh
