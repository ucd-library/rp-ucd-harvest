#! /usr/bin/make -f
SHELL:=/usr/bin/bash

VERBOSE:=
ifdef groups
user-groups:=--user-groups
endif

dir:=raw-records

types:=user publication relationship group

user.entry:=api:object
publication.entry:=api:object
relationship.entry:=api:relationship
group.entry:=api:user-group

$(foreach t,${types},$(eval $t.json:=$(patsubst %,%.json,$(wildcard ${dir}/$t/*[0-9]))))
json:=$(patsubst %,%.json,$(wildcard ${dir}/*/*[0-9]))

info::
	echo ${json}

.PHONY:ttl json

.PHONY:feed split

feed:
	elements ${VERBOSE} feed ${user-groups} groups users user-relationships publications relationships

split:
	elements ${VERBOSE} feed.split groups users publications relationships

# Conversion to TTL
# You can't use a straight context since jena doesn't understand jsonld 1.1
define context_jsonld_1.1
{"@context":{"@version":"1.1","@base":"http://oapolicy.ucdavis.edu/oap/","@vocab":"http://oapolicy.ucdavis.edu/oap/","oap":"http://oapolicy.ucdavis.edu/oap/","api":"http://oapolicy.ucdavis.edu/oap/api/","id":{"@id":"@id","@type":"@id"},"api:related":{"@context": {"id":{"@type":"@id"}}},"field-name":"api:field-name","field-number":"api:field-number","$$t":"api:field-value"}}
endef

# Instead use jq to set the "@id" paramter below
define context
{"@context":{"@base":"http://experts.ucdavis.edu/oap/","@vocab":"http://experts.ucdavis.edu/oap/vocab#","oap":"http://experts.ucdavis.edu/oap/vocab#","api":"http://experts.ucdavis.edu/oap/vocab#","id":{"@type":"@id"},"field-name":"api:field-name","field-number":"api:field-number","$$t":"api:field-value"}}
endef

# Instead use jq to set the "@id" paramter below
define id_context
{"@context":{"@base":"http://experts.ucdavis.edu/oap/","@vocab":"http://experts.ucdavis.edu/oap/vocab#","oap":"http://experts.ucdavis.edu/oap/vocab#","api":"http://experts.ucdavis.edu/oap/vocab#","id":{"@id":"@id","@type":"@id"},"field-name":"api:field-name","field-number":"api:field-number","$$t":"api:field-value","api:person":{"@container":"@list"},"api:first-name":{"@container":"@list"}}}
endef

# We need our data into break these into readable pieces
include parts.mk

parts.mk:sz:=1000
parts.mk:f:=parts.mk.ls
parts.mk:
	echo "# parts.mk" > $@;\
	for type in ${types}; do\
	  if [[ -d ${dir}/$${type} ]]; then \
		  find raw-records/$${type} -name \*.json > ${f};\
		  t=`wc -l ${f} | cut -d' ' -f 1`;\
		  echo -n "$${type}.parts:=" >> $@;\
		  for i in `seq -w 1 ${sz} $${t}`; do\
	  	  echo -n "$${type}.$${i} " >> $@;\
		  done;\
		  echo "" >> $@ ; \
		  for i in `seq -w 1 ${sz} $${t}`; do\
	   	  echo $${type}.$${i}.files:=`tail -n +$${i} ${f} | head -n ${sz}` >> $@; \
		  done;\
		  rm -f ${f};\
    fi;\
	done

$(foreach t,${types},$(eval $t.jsonld.gz:=$(patsubst %,%.jsonld.gz,${$t.parts})))
$(foreach t,${types},$(eval $t.ttl.gz:=$(patsubst %,%.ttl.gz,${$t.parts})))

ttl:=${publication.ttl.gz} ${user.ttl.gz} ${relationship.ttl.gz} group.ttl.gz


.PHONY:publication.jsonld.gz user.jsonld.gz relationship.jsonld.gz
user.jsonld.gz:${user.jsonld.gz}
publication.jsonld.gz:${publication.jsonld.gz}
relationship.jsonld.gz:${relationship.jsonld.gz}

.PHONY:publication.ttl.gz user.ttl.gz relationship.ttl.gz
user.ttl.gz:${user.ttl.gz}
publication.ttl.gz:${publication.ttl.gz}
relationship.ttl.gz:${relationship.ttl.gz}

group.jsonld.gz:%.jsonld.gz:${%.json}
	jq --slurp '${context} + {"@graph":(.[]|=with_entries(if .key=="id" then .key="@id" else . end))}' ${$*.json} | gzip > $@

${relationship.jsonld.gz}:%.jsonld.gz:${%.json}
	jq --slurp '${context} + {"@graph":(.[]|=with_entries(if .key=="id" then .key="@id" else . end))}' ${$*.files} | gzip > $@

${user.jsonld.gz} ${publication.jsonld.gz}:%.jsonld.gz:${%.json}
	jq --slurp '${id_context} + {"@graph":.}' ${$*.files} | gzip > $@

.PHONY:ttl
ttl:${ttl}

${ttl}:%.ttl.gz:%.jsonld.gz
	riot --formatted=ttl $< | gzip > $@

json:${json}
user.json:${user.json}
publication.json:${publication.json}
relationship.json:${relationship.json}

$(patsubst %,json/%,${types}):
	[[ -d $@ ]] || mkdir -p $@

${json}:%.json:%
	xml2json $< | jq '.entry["${$(notdir $(patsubst %/,%,$(dir $@))).entry}"]' > $@

clean:
	rm -f parts.mk *.jsonld.gz
