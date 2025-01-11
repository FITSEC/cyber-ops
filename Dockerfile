# =========================================================
# kali-rolling AS base
# =========================================================

FROM kalilinux/kali-rolling:latest AS base

LABEL maintainer="TJ <tj@tjoconnor.org>"
LABEL contributor="Louie <lorcinolo2020@my.fit.edu>"
LABEL contributor="Marcus <mfeliciano2021@my.fit.edu>"

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

RUN apt-get clean -y && \
    apt-get update -qq -y && \
    apt-get upgrade -qq -y

RUN apt-get install -qq -y nala

# =========================================================
# legacy architecture libraries 
# =========================================================

RUN dpkg --add-architecture i386 && \
    nala install --update -y -o APT::Immediate-Configure=false \
       libc6-i386 \
       libstdc++6:i386 \
       libc6-dev-i386 \
       --no-install-recommends

# =========================================================
# apt package installs
# =========================================================

RUN apt-get install -qq -y \
    bat \
    clang \
    cmake \
    curl \
    dos2unix \
    du-dust \
    g++ \
    gcc \
    gcc-12-plugin-dev \
    gcc-multilib \
    gdb-multiarch \
    gdbserver \
    git \
    libcapstone-dev \
    libedit-dev \
    librtlsdr-dev \
    libusb-1.0-0-dev \
    locales \
    make \
    man-db \
    nano \
    nasm \
    pkg-config \
    python2 \
    python2-dev \
    python3 \
    python3-dev \
    python3-pip \
    ruby \
    ruby-dev \
    sudo \
    vim \
    virtualenv \
    wget 

COPY packages.txt /opt/packages.txt

# RUN xargs -a /opt/packages.txt nala install -y

# ^^^ Now optional

# =========================================================
# pip3 package installs
# =========================================================

COPY requirements.txt /opt/requirements.txt
RUN dos2unix /opt/requirements.txt

RUN python3 -m virtualenv /opt/venv

RUN . /opt/venv/bin/activate && \
    python3 -m pip install --upgrade pip && \
    python3 -m pip install --no-cache-dir \
    -r /opt/requirements.txt && \
    rm /opt/requirements.txt

ENV PATH="/opt/venv/bin:$PATH"

# =========================================================
# pip2 legacy package installs
# =========================================================

COPY requirements-2.txt /opt/requirements-2.txt
RUN dos2unix /opt/requirements-2.txt

RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output /opt/get-pip.py && \
    python2 /opt/get-pip.py && rm /opt/get-pip.py

RUN python2 -m pip install crypto -r /opt/requirements-2.txt && rm /opt/requirements-2.txt

# =========================================================
# crypto tooling
# =========================================================

RUN git -C /opt/ clone https://github.com/Ganapati/RsaCtfTool

# =========================================================
# forensics tooling
# =========================================================

RUN git -C /opt/ clone https://github.com/volatilityfoundation/volatility.git && \
    chmod +x /opt/volatility/vol.py && \
    ln -s /opt/volatility/vol.py /usr/bin/vol.py && \
    ln -s /opt/volatility/vol.py /usr/bin/volatility && \
    sed -i '1s/.*/\#\!\/usr\/bin\/env python2/' /opt/volatility/vol.py

RUN git -C /opt/ clone https://github.com/craigz28/firmwalker.git


#RUN git clone https://github.com/sviehb/jefferson /opt/jefferson && \
#    cd /opt/jefferson && \
#    python3 setup.py install && \
#    cd / && \
#    rm -rf /opt/jefferson

# RUN git -C /opt/ clone https://github.com/devttys0/yaffshiv && \
#     python3 /opt/yaffshiv/setup.py install && \
#     rm -rf /opt/yaffshiv

RUN git -C /opt/ clone https://github.com/DidierStevens/DidierStevensSuite && \
    chmod +x /opt/DidierStevensSuite/oledump.py && \
    ln -sf /opt/DidierStevensSuite/oledump.py /usr/local/bin/oledump 

#RUN cd /opt/ && \
#    wget https://github.com/osquery/osquery/releases/download/5.14.1/osquery_5.14.1-1.linux_amd64.deb && \
#    dpkg -i osquery_5.14.1-1.linux_amd64.deb

# =========================================================
# wireless tooling
# =========================================================

RUN git -C /opt/ clone https://github.com/antirez/dump1090.git && \
    make -C /opt/dump1090/ && \
    ln -sf /opt/dump1090/dump1090 /usr/local/bin/dump1090

RUN git -C /opt/ clone https://github.com/atlas0fd00m/rfcat && \
    cd /opt/rfcat && \
    sed -i 's/ipython/#ipython/g' /opt/rfcat/requirements.txt && \
    python2 /opt/rfcat/setup.py install 

RUN git -C /opt/ clone https://github.com/IoTsec/Z3sec/ && \
    cd /opt/Z3sec/ && \
    python2 /opt/Z3sec/setup.py install

# =========================================================
# stego tooling 
# =========================================================

RUN wget http://www.caesum.com/handbook/Stegsolve.jar -O /opt/stegsolve.jar && \
    chmod +x /opt/stegsolve.jar && \
    mkdir /opt/bin && \
    mv /opt/stegsolve.jar /opt/bin/

RUN wget -O /usr/local/bin/jsteg \
   https://github.com/lukechampine/jsteg/releases/download/v0.3.0/jsteg-linux-amd64 && \
   chmod +x /usr/local/bin/jsteg

RUN wget -O /usr/local/bin/slink \
   https://github.com/lukechampine/jsteg/releases/download/v0.3.0/slink-linux-amd64 && \
   chmod +x /usr/local/bin/slink

# =========================================================
# RE tooling
# =========================================================

RUN gem install one_gadget seccomp-tools

RUN python3 -m pip install --upgrade --ignore-installed pycparser

RUN git -C /opt/ clone https://github.com/angr/angrop && \
    python3 -m pip install /opt/angrop/

RUN python3 -m pip install https://github.com/angr/pypcode/archive/refs/heads/master.zip

RUN git -C /opt/ clone https://github.com/axt/bingraphvis && \
    python3 -m pip install -e ./opt/bingraphvis

RUN git -C /opt/ clone https://github.com/axt/angr-utils && \
    python3 -m pip install -e ./opt//angr-utils

RUN git -C /opt/ clone https://github.com/xoreaxeaxeax/movfuscator && \
   cd /opt/movfuscator && \
   ./build.sh && \
   ./install.sh

RUN git -C /opt/ clone https://github.com/yrp604/rappel && \
    CC=clang make -C /opt/rappel
ENV PATH=$PATH:/opt/rappel/bin/

RUN git -C /opt/ clone https://github.com/ChrisTheCoolHut/call_trace && \
    make -C /opt/call_trace/
ENV PATH=$PATH:/opt/call_trace/build/

COPY tigress_4.0.10-1_all.deb.zip /opt/.
RUN unzip /opt/tigress_4.0.10-1_all.deb.zip -d /opt/ && \
    dpkg -i /opt/tigress_4.0.10-1_all.deb && rm /opt/tigress_4.0.10-1_all.deb.zip && \
    rm /opt/tigress_4.0.10-1_all.deb

# ENV C_INCLUDE_PATH="/usr/local/bin/tigresspkg/4.0.10:$C_INCLUDE_PATH"  
ENV C_INCLUDE_PATH="/usr/local/bin/tigresspkg/4.0.10:${C_INCLUDE_PATH:-}"

# =========================================================
# pwn tooling
# =========================================================

RUN git -C /opt/ clone https://gitlab.com/akihe/radamsa.git && \
    make -C /opt/radamsa && make install -C /opt/radamsa

RUN wget -O /opt/pwndbg_2024.08.29_amd64.deb https://github.com/pwndbg/pwndbg/releases/download/2024.08.29/pwndbg_2024.08.29_amd64.deb -O /opt/pwndbg_2024.08.29_amd64.deb && \
    dpkg -i /opt/pwndbg_2024.08.29_amd64.deb && rm /opt/pwndbg_2024.08.29_amd64.deb

RUN mkdir /opt/getsome && \
    wget https://raw.githubusercontent.com/datajerk/ctf-write-ups/master/redpwnctf2021/getsome_beginner-generic-pwn-number-0_ret2generic-flag-reader_ret2the-unknown/getsome.py -O /opt/getsome.py

RUN git -C /opt/ clone --depth 1 https://github.com/shellphish/how2heap

RUN wget -O /bin/pwninit https://github.com/io12/pwninit/releases/download/3.3.1/pwninit && \
    chmod +x /bin/pwninit 
COPY pwn-skeleton.py /opt/pwn-skeleton.py
RUN dos2unix /opt/pwn-skeleton.py
RUN git -C /opt/ clone https://github.com/niklasb/libc-database

# =========================================================
# cross-architecture arm support
# =========================================================

RUN dpkg --add-architecture armhf && \
    dpkg --add-architecture armel && \
    nala update && \
    apt-get install -qq -y -o APT::Immediate-Configure=false \
       gcc-aarch64-linux-gnu \
       gcc-arm-linux-gnueabi \
       gcc-arm-linux-gnueabihf \
       binutils-aarch64-linux-gnu \
       --no-install-recommends 

# =========================================================
# cleanup
# =========================================================

RUN rm -rf /root/.cache/pip && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/lib/gems/2.*/cache/* \z

RUN touch ~/.hushlogin

# =========================================================
# local environment
# =========================================================

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8 
ENV PWNDBG_NO_AUTOUPDATE=1
ENV DISPLAY=host.docker.internal:0.0

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.1/zsh-in-docker.sh)" -- \
    -t crunch

WORKDIR /root/workspace
RUN cd /root/workspace
RUN chsh -s /bin/zsh
RUN echo "alias ggdb='/bin/gdb'" >> /root/.zshrc && echo "alias gdb='pwndbg'" >> /root/.zshrc
RUN echo "alias pwninit='pwninit --template-path /opt/pwn-skeleton.py --template-bin-name e'" >> /root/.zshrc

# RUN echo "source /opt/venv/bin/activate" >> /root/.zshrc
# RUN echo "source /opt/venv/bin/activate" >> /root/.tmux.conf
# RUN echo "set-option -g default-shell /bin/zsh" > /root/.tmux.conf

RUN echo freedom-spr25 > /opt/version

COPY install.sh /opt/install.sh
RUN dos2unix /opt/install.sh
RUN chmod +x /opt/install.sh

ENTRYPOINT ["/bin/zsh"]
