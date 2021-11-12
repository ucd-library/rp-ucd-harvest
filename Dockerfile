# Now create our version
FROM openjdk:11-jdk

# Get JENA binaries
COPY --from=stain/jena:3.14.0 /jena /jena/
ENV PATH=$PATH:/jena/bin

# Add httpie for URL grabs
RUN apt-get update && apt-get install -y build-essential make httpie perl git jq xmlstarlet rsync && rm -rf /var/lib/apt/lists/*

# Add node

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs
RUN cd && npm install xml2json
#RUN echo '# xml2json path fix\nPATH=$PATH:/root/node_modules/.bin' >> /root/.bashrc
env PATH $PATH:/root/node_modules/.bin

# Add our elements
COPY cdl-elements /cdl-elements/
RUN make --directory=/cdl-elements prefix=/usr/local install && rm -rf /cdl-elements

# Add our aeq tool
COPY aeq /aeq/
RUN make --directory=/aeq prefix=/usr/local install && rm -rf /aeq

# Add IAM query, cdl query and harvest
COPY ucdid /usr/local/bin
COPY harvest /usr/local/bin
COPY lib /usr/local/lib/harvest

# Our entrypoint calls the generic VIVO one
COPY rp-ucd-harvest-entrypoint.sh /

ENTRYPOINT ["/rp-ucd-harvest-entrypoint.sh"]
CMD ["/bin/echo", "rp-ucd-harvester"]
