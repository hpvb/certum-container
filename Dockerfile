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
RUN 	dnf -y install --setopt=install_weak_deps=False \
		libX11 libXext libXcomposite libXi libICE libSM libXrender libxcb libXau\
		pcsc-lite-libs libglvnd-glx tigervnc-server-minimal stalonetray fontconfig\
		pulseaudio-libs-glib2 p11-kit-server libxslt procps-ng monit && \
	dnf clean all && \
	rm -rf /usr/lib64/dri/* && \
	rm -rf /usr/lib64/libgallium-25.0.7.so && \
	rm -rf /usr/lib64/gallium-pipe && \
	rm -rf /usr/lib64/llvm20

# Install SimplySignDesktop
RUN	curl -O https://files.certum.eu/software/SimplySignDesktop/Linux-RedHat/2.9.10-9.2.14.0/SimplySignDesktop-2.9.10-9.2.14.0-x86_64-prod-centos.bin && \
	echo "1bb72568f27ceb46aaa2906d3347dd49c72ea4795eded79f7b3ecb18b6379947  SimplySignDesktop-2.9.10-9.2.14.0-x86_64-prod-centos.bin" | sha256sum -c && \
	yes yes | sh SimplySignDesktop-2.9.10-9.2.14.0-x86_64-prod-centos.bin --target /root/certum && \
	rm -f SimplySignDesktop-2.9.10-9.2.14.0-x86_64-prod-centos.bin && \
	mv /root/certum/SSD-2.9.10-dist /opt/SimplySignDesktop/ && \
	rm -rf certum && \
	cp /opt/SimplySignDesktop/SimplySignDesktop.xml /root 

COPY	files /
RUN	chmod +x /usr/local/bin/* && \
	chmod 0600 /etc/monitrc

VOLUME  /run/p11-kit
EXPOSE  5900

ENTRYPOINT /usr/local/bin/entrypoint.sh
