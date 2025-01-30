###################################################################################################
# A custom Docker image for advanced deployments that use the OAuth Proxy and Phantom Token plugins
###################################################################################################
FROM kong/kong:3.9

USER root
RUN apt-get update
RUN apt-get install -y git unzip

#
# Install luarocks, and set git options if required
#
RUN git config --global url."https://".insteadOf git:// && \
    git config --global advice.detachedHead false
    
#
# Install the OAuth Proxy plugin and its dependencies
#
COPY download/plugin/* /tmp/oauth-proxy/
RUN cd /tmp/oauth-proxy && luarocks make oauth-proxy-*.rockspec \
    && cd / && rm -r /tmp/oauth-proxy 

#
# Install the Phantom Token plugin and its dependencies
#
RUN luarocks install kong-phantom-token 2.0.0

#
# Add environment variables required to use plugins
#
ENV KONG_NGINX_HTTP_LUA_SHARED_DICT='phantom-token 10m'
ENV KONG_PLUGINS='bundled,cors,oauth-proxy,phantom-token'
