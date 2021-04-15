PREFIX bibo: <http://purl.org/ontology/bibo/>
PREFIX cite: <http://citationstyles.org/schema/>
PREFIX experts: <http://experts.ucdavis.edu/>
PREFIX experts_oap: <http://experts.ucdavis.edu/oap/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX harvest_oap: <http://oapolicy.universityofcalifornia.edu/>
PREFIX list: <http://jena.apache.org/ARQ/list#>
PREFIX oap: <http://oapolicy.universityofcalifornia.edu/vocab#>
PREFIX oapx: <http://experts.ucdavis.edu/oap/vocab#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX person: <http://experts.ucdavis.edu/person/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX vcard: <http://www.w3.org/2006/vcard/ns#>
PREFIX vivo: <http://vivoweb.org/ontology/core#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX FoR: <http://experts.ucdavis.edu/concept/FoR/>
PREFIX ucdrp: <http://experts.ucdavis.edu/schema#>

# First, Insert citation BIBO stuff
INSERT {
  # Remember we have concepts
  GRAPH harvest_oap: {
    ?user oap:user_supplied_concepts ?user_supplied_concepts;
    }
	GRAPH experts_oap: {
    ?person_id a ucdrp:person, foaf:Person;
       rdfs:label ?name ;
       vivo:overview ?overview;
       obo:ARG_2000028 ?vcard;
       ucdrp:oapolicyId ?oapolicy_id;
       .

  ?person_id ucdrp:identifier ?identifier_oapolicy_id.
  ?identifier_oapolicy_id a ucdrp:Identifier;
    ucdrp:scheme "oapolicy";
    ucdrp:value  ?oapolicy_id;
    .

  ?person_id ?id_pred ?id_value.

  ?person_id ucdrp:identifier ?assoc_identifier.
    ?assoc_identifier a ucdrp:Identifier;
      ucdrp:scheme ?assoc_scheme;
      ucdrp:value  ?assoc_value;
      .

    ?vcard a vcard:Individual;
           ucdrp:identifier "oap-1";
           vivo:rank 20 ;
    vcard:hasName ?vcard_name;
#    vcard:hasTitle ?vcard_title;
    vcard:hasEmail ?vcard_email;
    .

    ?vcard_name a vcard:Name;
                vcard:givenName ?fn;
                vcard:familyName ?ln;
                .
    ?vcard_email  a vcard:Email,vcard:Work;
                  vcard:email ?email;
                  .


#    ?vcard_title a vcard:Title;
#                 vcard:title ?position;
#                 vcard:hasOrganizationalUnit ?vcard_org_unit
#                 .

#    ?vcard_org_unit a vcard:Organization;
#                    vcard:title ?dept;
#                    .

    # Research Areas
    ?person_id vivo:hasResearchArea ?concept.
    ?concept vivo:ResearchAreaOf ?person_id.

  }
}
WHERE { GRAPH harvest_oap: {
  ?user oap:category "user";
        oap:experts_person_id ?person_id;
        oap:last-name ?ln;
        oap:first-name ?fn;
        oap:user-identifier-associations ?assoc;
        .


  bind(concat(?fn," ",?ln) as ?name)
  bind(uri(concat(str(?person_id),"#vcard")) as ?vcard)
  bind(uri(concat(str(?person_id),"#vcard-name")) as ?vcard_name)

  ?assoc oap:user-id ?oapolicy_id.
  bind(uri(concat(str(?person_id),"#oapolicyId")) as ?identifier_oapolicy_id)

  OPTIONAL {
#    values ?assoc_scheme { "researcherid" "orcid" "scopus-author-id" "figshare-for-institutions-user-account-id" }
    values ?assoc_scheme { "researcherid" "orcid" "scopus-author-id" "figshare-for-institutions-user-account-id" }
    ?assoc oap:user-identifier-association [ oap:field-value  ?assoc_value ; oap:scheme ?assoc_scheme ].
  }
  bind(uri(concat(str(?person_id),"#identifier-",?assoc_scheme,"-",?assoc_value)) as ?assoc_identifier)

  OPTIONAL {
    values (?oap_scheme ?id_pred) {
      ("researcherid" vivo:researcherId)
      ("orcid" vivo:orcidId)
      ("scopus-author-id" vivo:scopusId) }
    ?assoc oap:user-identifier-association [ oap:field-value  ?id_value ; oap:scheme ?oap_scheme ].
  }

  OPTIONAL {
    ?user oap:records/oap:record/oap:native ?native.
    OPTIONAL {
      ?native oap:field [ oap:name "email-addresses";
                          oap:type "email-address-list";
                          oap:email-addresses [
                                                oap:email-address [
                                                                    oap:address ?email;
                                                                    oap:privacy "public";
                                                                  ]
                                              ]
                        ].
      }
    OPTIONAL {
      ?native oap:field [ oap:name "overview";
                          oap:text/oap:field-value ?overview;
                        ].
      }
  }
  bind(uri(concat(str(?person_id),"#",md5(?email))) as ?vcard_email)

  OPTIONAL {
    values (?scheme ?vocab) { ("for" FoR:) }
       ?user oap:all-labels [
                           oap:type "keyword-list";
                           oap:keywords/oap:keyword [
                                                      oap:field-value ?value;
                                                      oap:scheme ?scheme;
                                                    ]
                         ].
    bind(uri(concat(str(?vocab),replace(?value," .*",""))) as ?concept)
    bind(true as ?keyword_list)
    }
  bind(coalesce(?keyword_list,false) as ?user_supplied_concepts)
}}
