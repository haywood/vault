FROM centos:centos7
RUN yum install -q -y epel-release
RUN yum install -q -y libgit2-devel
RUN yum install -q -y python-devel
RUN yum install -q -y python-setuptools
RUN easy_install pip
RUN yum install -q -y libffi-devel
RUN yum install -q -y gcc
RUN pip install pygit2
RUN yum install -q -y make
RUN yum install -q -y git
RUN yum install -q -y tar
RUN git config --global --add user.name vault
RUN git config --global --add user.email vault
ADD gpg_params.txt /tmp/gpg_params.txt
RUN yum install -q -y rng-tools
RUN rngd -r /dev/urandom -o /dev/urandom
RUN gpg --gen-key --batch /tmp/gpg_params.txt
VOLUME ["/opt/vault"]
WORKDIR /opt/vault
