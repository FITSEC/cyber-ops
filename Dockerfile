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

# =========================================================
# legacy architecture libraries 
# =========================================================

RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get -y install -o APT::Immediate-Configure=false \
       libc6-i386 \
       libstdc++6:i386 \
       libc6-dev-i386 \
       --no-install-recommends

# =========================================================
# apt package installs
# =========================================================

COPY packages.txt /opt/packages.txt

RUN xargs -a /opt/packages.txt apt-get install \
    -qq -y --ignore-missing --fix-missing 

# =========================================================
# pip3 package installs
# =========================================================

COPY requirements.txt /opt/requirements.txt

RUN python3 -m virtualenv /opt/venv

RUN . /opt/venv/bin/activate && \
    python3 -m pip install --upgrade pip && \
    python3 -m pip install --no-cache-dir \
    -r /opt/requirements.txt

ENV PATH="/opt/venv/bin:$PATH"

# =========================================================
# pip2 legacy package installs
# =========================================================

COPY requirements-2.txt /opt/requirements-2.txt

RUN cd /opt/ && \
    curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py && \
    python2 get-pip.py

RUN python2 -m pip install crypto -r /opt/requirements-2.txt

# =========================================================
# crypto tooling
# =========================================================

RUN cd /opt/ && git clone https://github.com/Ganapati/RsaCtfTool

# =========================================================
# forensics tooling
# =========================================================

RUN cd /opt/ && git clone https://github.com/volatilityfoundation/volatility.git && \
  chmod +x volatility/vol.py && \
  ln -s /opt/volatility/vol.py /usr/bin/vol.py && \
  ln -s /opt/volatility/vol.py /usr/bin/volatility && \
  sed -i '1s/.*/\#\!\/usr\/bin\/env python2/' /opt/volatility/vol.py

RUN cd /opt/ && \
    git clone https://github.com/craigz28/firmwalker.git 

#RUN git clone https://github.com/sviehb/jefferson /opt/jefferson && \
#    cd /opt/jefferson && \
#    python3 setup.py install && \
#    cd / && \
#    rm -rf /opt/jefferson

RUN git clone https://github.com/devttys0/yaffshiv /opt/yaffshiv && \
    cd /opt/yaffshiv && \
    python3 setup.py install && \
    cd / && \
    rm -rf /opt/yaffshiv

RUN cd /opt/ && \
    git clone https://github.com/DidierStevens/DidierStevensSuite && \
    chmod +x /opt/DidierStevensSuite/oledump.py && \
    ln -sf /opt/DidierStevensSuite/oledump.py /usr/local/bin/oledump 

#RUN cd /opt/ && \
#    wget https://github.com/osquery/osquery/releases/download/5.14.1/osquery_5.14.1-1.linux_amd64.deb && \
#    dpkg -i osquery_5.14.1-1.linux_amd64.deb

# =========================================================
# wireless tooling
# =========================================================

RUN cd /opt && \
    git clone https://github.com/antirez/dump1090.git && \
    cd dump1090 && \
    make && \
    ln -sf /opt/dump1090/dump1090 /usr/local/bin/dump1090

RUN cd /opt/ && \
    git clone https://github.com/atlas0fd00m/rfcat && \
    cd rfcat && \
    sed 's/ipython/#ipython/g' requirements.txt > requirements.mod && \
    mv requirements.mod requirements.txt && \
    python2 setup.py install 

RUN cd /opt/ && \
    git clone https://github.com/IoTsec/Z3sec/ && \
    cd Z3sec && \
    python2 setup.py install

# =========================================================
# stego tooling 
# =========================================================

RUN cd /opt && \
    wget http://www.caesum.com/handbook/Stegsolve.jar -O stegsolve.jar && \
    chmod +x stegsolve.jar && \
    mkdir bin && \
    mv stegsolve.jar bin/

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
RUN cd /opt/ && git clone https://github.com/angr/angrop && \
    cd angrop && python3 -m pip install . 
RUN python3 -m pip install https://github.com/angr/pypcode/archive/refs/heads/master.zip

RUN cd /opt && git clone https://github.com/axt/bingraphvis && \
    python3 -m pip install -e ./bingraphvis

RUN cd /opt && git clone https://github.com/axt/angr-utils && \
    python3 -m pip install -e ./angr-utils

RUN cd /opt && \
   git clone https://github.com/xoreaxeaxeax/movfuscator && \
   cd movfuscator && \
   ./build.sh && \
   ./install.sh

RUN cd /opt/ && \
    git clone https://github.com/yrp604/rappel && \
    cd rappel && CC=clang make
ENV PATH=$PATH:/opt/rappel/bin/

RUN cd /opt/ && \
    git clone https://github.com/ChrisTheCoolHut/call_trace && \
    cd call_trace && make
ENV PATH=$PATH:/opt/call_trace/build/

COPY tigress_4.0.10-1_all.deb.zip /opt/.
RUN cd /opt && unzip tigress_4.0.10-1_all.deb.zip && \
    dpkg -i tigress_4.0.10-1_all.deb
# ENV C_INCLUDE_PATH="/usr/local/bin/tigresspkg/4.0.10:$C_INCLUDE_PATH"  
ENV C_INCLUDE_PATH="/usr/local/bin/tigresspkg/4.0.10:${C_INCLUDE_PATH:-}"

# =========================================================
# pwn tooling
# =========================================================

RUN cd /opt/ && git clone https://gitlab.com/akihe/radamsa.git && \
    cd radamsa && make && sudo make install

# RUN cd /opt && git clone https://github.com/pwndbg/pwndbg && \
#     cd pwndbg && ./setup.sh --update

RUN wget -O /opt/pwndbg_2024.08.29_amd64.deb https://github.com/pwndbg/pwndbg/releases/download/2024.08.29/pwndbg_2024.08.29_amd64.deb && \
    dpkg -i /opt/pwndbg_2024.08.29_amd64.deb && rm /opt/pwndbg_2024.08.29_amd64.deb

RUN cd /opt/ && \
    mkdir getsome && \
    cd getsome && \
    wget https://raw.githubusercontent.com/datajerk/ctf-write-ups/master/redpwnctf2021/getsome_beginner-generic-pwn-number-0_ret2generic-flag-reader_ret2the-unknown/getsome.py

RUN cd /opt/ && \
    git clone --depth 1 https://github.com/shellphish/how2heap how2heap

RUN wget -O /bin/pwninit https://github.com/io12/pwninit/releases/download/3.3.1/pwninit && \
    chmod +x /bin/pwninit 
COPY pwn-skeleton.py /opt/pwn-skeleton.py
RUN echo "alias pwninit='pwninit --template-path /opt/pwn-skeleton.py --template-bin-name e'" >> /root/.zshrc

RUN cd /opt/ && \
    git clone https://github.com/niklasb/libc-database && \
    cd /opt/libc-database 
#    &&\    ./get ubuntu 

# =========================================================
# cross-architecture arm support
# =========================================================

RUN dpkg --add-architecture armhf && \
    dpkg --add-architecture armel && \
    apt-get -qq update -y && \
    apt-get -qq -y install -o APT::Immediate-Configure=false \
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
    rm -rf /var/lib/gems/2.*/cache/*

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
# RUN echo "source /opt/venv/bin/activate" >> /root/.zshrc
# RUN echo "source /opt/venv/bin/activate" >> /root/.tmux.conf
# RUN echo "set-option -g default-shell /bin/zsh" > /root/.tmux.conf

RUN echo freedom-spr25 > /opt/version

ENTRYPOINT ["/bin/zsh"]
