FROM tsturzl/alpine-elixir:1.5.3 as builder

ENV HOME=/opt/app/ TERM=xterm

VOLUME /tmp

WORKDIR /opt/app

ENV MIX_ENV=prod

RUN mkdir config
COPY config/* config/
COPY mix.exs mix.lock ./

COPY . .

RUN mix local.hex --force
RUN mix local.rebar --force

RUN mix release --verbose --no-tar
RUN cd _build/prod/rel/oddcarl && tar zcf /opt/app/oddcarl.tar.gz .

########################################################################################################################

FROM tsturzl/alpine-erlang:latest

ENV MIX_ENV=prod REPLACE_OS_VARS=true SHELL=/bin/sh

COPY ./VERSION .
COPY --from=builder /opt/app/oddcarl.tar.gz ./
RUN tar -xzf oddcarl.tar.gz && rm oddcarl.tar.gz
RUN chown -R default ./releases
RUN chown -R default /opt/app

USER default

ENTRYPOINT ["/opt/app/bin/oddcarl", "foreground"]

