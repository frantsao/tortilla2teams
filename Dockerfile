FROM opensuse/leap:15.2 AS build
RUN \
  zypper in -y gcc dmd dub zlib-devel libopenssl-devel phobos-devel-static
COPY . /usr/src
WORKDIR /usr/src
RUN DUB=/usr/bin/dub dub -v build

FROM opensuse/leap:15.2
RUN \
  groupadd -r nobody && \
  useradd -r -s /bin/false -g nobody nobody && \
  zypper in -y libz1 libopenssl1_1 libphobos2-0_85
COPY --from=build /usr/src/tortilla2teams /bin

USER nobody
ENTRYPOINT ["/bin/tortilla2teams"]
