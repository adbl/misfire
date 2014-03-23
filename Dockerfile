FROM adbl/elixir:v0.12.5

WORKDIR /tmp
RUN git clone https://github.com/rebar/rebar.git
WORKDIR /tmp/rebar
RUN git checkout 2.2.0
RUN ./bootstrap
RUN cp rebar /usr/local/bin
RUN rm -rf /tmp/rebar

ADD . /opt/misfire
WORKDIR /opt/misfire
mix deps.get
mix deps.compile
mix compile
mix test
EXPOSE 4000
CMD cd /opt/misfire && mix run --no-halt
