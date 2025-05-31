FROM amazonlinux:2023

ENV HOME=/root

RUN yum install -y \
    git \
    tar \
    gzip \
    make \
    unzip \
    shadow-utils && \
    usermod -aG wheel root && \
    git clone https://github.com/tfutils/tfenv.git ~/.tfenv && \
    echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(tfenv init -)"' >> ~/.bashrc

RUN dnf install -y findutils which

WORKDIR /root/bastion-container

CMD [ "sleep", "infinity" ]
