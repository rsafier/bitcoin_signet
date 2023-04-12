FROM archlinux as custom-signet-bitcoin

LABEL org.opencontainers.image.authors="NBD"
LABEL org.opencontainers.image.licenses=MIT
LABEL org.opencontainers.image.source="https://github.com/nbd-wtf/bitcoin_signet"

ENV BITCOIN_DIR /root/.bitcoin 

ENV NBITS=${NBITS}
ENV SIGNETCHALLENGE=${SIGNETCHALLENGE}
ENV PRIVKEY=${PRIVKEY}

ENV RPCUSER=${RPCUSER:-"bitcoin"}
ENV RPCPASSWORD=${RPCPASSWORD:-"bitcoin"}
ENV COOKIEFILE=${COOKIEFILE:-"false"}
ENV ONIONPROXY=${ONIONPROXY:-""}
ENV TORPASSWORD=${TORPASSWORD:-""}
ENV TORCONTROL=${TORCONTROL:-""}
ENV I2PSAM=${I2PSAM:-""}

ENV UACOMMENT=${UACOMMENT:-"CustomSignet"}
ENV ZMQPUBRAWBLOCK=${ZMQPUBRAWBLOCK:-"tcp://0.0.0.0:28332"}
ENV ZMQPUBRAWTX=${ZMQPUBRAWTX:-"tcp://0.0.0.0:28333"}
ENV ZMQPUBHASHBLOCK=${ZMQPUBHASHBLOCK:-"tcp://0.0.0.0:28334"}

ENV RPCBIND=${RPCBIND:-"0.0.0.0:38332"}
ENV RPCALLOWIP=${RPCALLOWIP:-"0.0.0.0/0"}
ENV WHITELIST=${WHITELIST:-"0.0.0.0/0"}
ENV ADDNODE=${ADDNODE:-""}
ENV BLOCKPRODUCTIONDELAY=${BLOCKPRODUCTIONDELAY:-""}
ENV MINERENABLED=${MINERENABLED:-"1"}
ENV MINETO=${MINETO:-""}
ENV EXTERNAL_IP=${EXTERNAL_IP:-""} 
ENV SIGNET_BLOCKTIME=${SIGNET_BLOCKTIME:-"10"}

VOLUME $BITCOIN_DIR
EXPOSE 28332 28333 28334 38332 38333 38334

RUN  pacman -Sy  --noconfirm 
RUN pacman --sync  --noconfirm --needed autoconf automake boost gcc git libevent libtool make pkgconf python sqlite db python-pip patch bison

 
    
RUN  git clone https://github.com/benthecarman/bitcoin.git && \
     cd bitcoin && \
     git checkout configure-signet-blockitme 
RUN  cd bitcoin && \
     make -j $(nproc) -C depends NO_QT=1
RUN  cd bitcoin && \ 
     export BDB_PREFIX="/bitcoin/depends/x86_64-pc-linux-gnu" && \
     ./autogen.sh && \           
     ./configure \
     --with-incompatible-bdb \
     --disable-bench \
     --disable-tests \
     --with-gui=no  \
     --prefix=$BDB_PREFIX \
     BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" \
     BDB_CFLAGS="-I${BDB_PREFIX}/include" && \
     make -j $(nproc)  && \
     make install
COPY docker-entrypoint.sh /usr/local/bin/entrypoint.sh 
COPY *.sh /usr/local/bin/
COPY rpcauth.py /usr/local/bin/rpcauth.py
RUN pip3 install setuptools base58
RUN  cp /bitcoin/depends/x86_64-pc-linux-gnu/bin/* /usr/local/bin

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["run.sh"]