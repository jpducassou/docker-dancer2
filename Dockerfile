FROM debian:8.5

MAINTAINER "Jean Pierre Ducassou" <jpducassou@gmail.com>

# ============================================================================
# Config
# ============================================================================
# Unpriviled user uid. Should be $(id -u)
ARG UID
ENV UID=$UID
ARG PERLBREW_ROOT=/opt/perlbrew
ENV PERLBREW_ROOT=$PERLBREW_ROOT
ARG perl_version=perl-5.18.4
ENV perl_version=$perl_version
ARG perl_options="-j 4 -Dusethreads -Duselargefiles --notest"

# ============================================================================
# apt config
# ============================================================================
RUN echo "Acquire::Retries 5;" >> /etc/apt/apt.conf

RUN \
	if [ -n $http_proxy ]; then \
		echo "Acquire::http::proxy  \"${http_proxy}\";"  >> /etc/apt/apt.conf; \
	fi

RUN \
	if [ -n $https_proxy ]; then \
		echo "Acquire::https::proxy \"${https_proxy}\";" >> /etc/apt/apt.conf; \
	fi

# ============================================================================
# System packages
# ============================================================================
RUN apt-get clean \
	&& apt-get -yq update \
	&& apt-get install -yq --no-install-recommends \
		curl build-essential make ca-certificates \
		libssl-dev libxml2-dev libxslt1-dev \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# ============================================================================
# Perlbrew installation
# ============================================================================
RUN mkdir -p "${PERLBREW_ROOT}" \
	&& curl -kL http://install.perlbrew.pl | bash

# ============================================================================
# Install specific perl
# ============================================================================
RUN bash -c "source ${PERLBREW_ROOT}/etc/bashrc && perlbrew install ${perl_version} ${perl_options}" \
	&& rm -rf ${PERLBREW_ROOT}/{build,dists}/*
RUN bash -c "source ${PERLBREW_ROOT}/etc/bashrc && perlbrew install-cpanm"

# ============================================================================
# Create dancer user
# ============================================================================
RUN adduser \
	--shell "/bin/bash" \
	--home /home/dancer \
	--disabled-password \
	--gecos "dancer user" \
	-u "${UID}" dancer

# ============================================================================
# As dancer user
# ============================================================================
USER dancer
WORKDIR /home/dancer

# ============================================================================
# perl/cpanm workspace
# ============================================================================
RUN mkdir .perlbrew
VOLUME [".perlbrew"]

RUN mkdir .cpanm
VOLUME [".cpanm"]

# ============================================================================
# Utilities
# ============================================================================
ADD run           /home/dancer
ADD install_deps  /home/dancer

# ============================================================================
# Child image steps
# ============================================================================
ONBUILD ADD . /home/dancer
ONBUILD RUN /home/dancer/install_deps

# ============================================================================
# Execution
# ============================================================================
EXPOSE 5000
ENTRYPOINT ["/home/dancer/run"]
CMD ["plackup", "-r", "bin/app.psgi"]

