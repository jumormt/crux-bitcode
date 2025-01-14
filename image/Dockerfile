FROM mbarbar/crux:3.5

ENV HOME="/root"

# Copy our ports snapshot over.
COPY ports/core /usr/ports/core

# Tell prt-get about contrib and bc.
RUN echo prtdir /usr/ports/contrib/ >> /etc/prt-get.conf
RUN echo prtdir /usr/ports/bc/ >> /etc/prt-get.conf

# Modify default pkgmk.conf
RUN sed -i 's/# export JOBS/export JOBS/' /etc/pkgmk.conf
RUN sed -i 's/# export MAKEFLAGS/export MAKEFLAGS/' /etc/pkgmk.conf

# Handle some special cases before a full system update.
COPY pre-sysup.sh /bin
RUN pre-sysup.sh

# Update core.
RUN prt-get -is -if sysup

COPY ports/opt /usr/ports/opt

# Build LLVM that we'll use to build other software with GLLVM.
RUN prt-get -is -if --install-scripts depinst llvm
RUN prt-get -is -if --install-scripts depinst compiler-rt 
RUN prt-get -is -if --install-scripts depinst clang

# Install GLLVM. No need for a port; this is a throwaway container.
COPY ports/contrib /usr/ports/contrib
RUN prt-get depinst -is --install-scripts git
RUN prt-get depinst -is --install-scripts go
RUN go get github.com/SRI-CSL/gllvm/cmd/...
ENV PATH="${HOME}/go/bin/:${PATH}"

# Install qt5 since it is a large common dependency.
COPY ports/xorg /usr/ports/xorg
RUN prt-get depinst -is -if --install-scripts qt5

# Install SCC.
RUN go get -u github.com/boyter/scc/

# Install zip.
RUN prt-get -is --install-scripts depinst zip

# Install Lua.
RUN prt-get depinst -is -if --install-scripts lua53

# Actually use GLLVM.
ENV CC=gclang
ENV CXX=gclang++

# Move gclang to a lower precedence in PATH and overwrite all C compilers,
# including gclang, with cc.sh which will solve some of our CFLAGS woes
# and hardcoded gcc.
# TODO: does hardcoded clang appear?
COPY shell.lua /usr/share/lua/5.3/shell.lua

RUN mv "$HOME/go/bin/gclang" /bin/gclang
COPY cc.lua /usr/bin/gclang
COPY cc.lua /usr/bin/gcc
COPY cc.lua /usr/bin/cc

# Repeat for C++ compilers.
RUN mv "$HOME/go/bin/gclang++" /bin/gclang++
COPY cxx.lua /usr/bin/gclang++
COPY cxx.lua /usr/bin/g++
COPY cxx.lua /usr/bin/cxx

ENV PKGS_FILE "/etc/pkgs.txt"
ENV BC_DIR "$HOME/bitcode"
ENV SRC_DIR "$HOME/source"

# Our script which builds bitcode.
COPY build-bitcode.lua "/usr/bin/build-bitcode"
# Our script which counts LOC for built bitcode.
COPY loc.awk "/usr/bin/loc"

WORKDIR "$HOME"
