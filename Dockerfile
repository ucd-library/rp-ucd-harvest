# Now create our version
FROM openjdk:11-jdk

# VIVO Havester Section
COPY --from=ucdlib/vivo_harvester:v2 /usr/local/vivo /usr/local/vivo/
COPY --from=ucdlib/vivo_harvester:v2 /usr/local/bin/docker-vivo-harvester-entrypoint.sh /usr/local/bin/

COPY config/*.properties /etc/vivo/harvester/
COPY config/scripts /etc/vivo/harvester/scripts/

# Get JENA binaries
COPY --from=stain/jena:3.14.0 /jena /jena/
ENV PATH=$PATH:/jena/bin

# Add httpie for URL grabs
RUN apt-get update && apt-get install -y make httpie perl git xmlstarlet rsync && rm -rf /var/lib/apt/lists/*

# Add our elements
COPY elements /elements/
RUN make --directory=/elements prefix=/usr/local install && rm -rf /elements

# Add iam tool
COPY ucdid /usr/local/bin

# Our entrypoint calls the generic VIVO one
COPY rp-ucd-harvest-entrypoint.sh /

ENTRYPOINT ["/rp-ucd-harvest-entrypoint.sh"]
CMD ["/bin/echo", "rp-ucd-harvester"]
