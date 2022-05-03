PREFIX FoR: <http://experts.ucdavis.edu/concept/FoR/>
PREFIX aeq: <http://experts.ucdavis.edu/queries/schema#>
PREFIX afn: <http://jena.apache.org/ARQ/function#>
PREFIX authorship: <http://experts.ucdavis.edu/authorship/>
PREFIX bibo: <http://purl.org/ontology/bibo/>
PREFIX experts: <http://experts.ucdavis.edu/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX free: <http://experts.ucdavis.edu/concept/free>
PREFIX harvest_iam: <http://iam.ucdavis.edu/>
PREFIX harvest_oap: <http://oapolicy.universityofcalifornia.edu/>
PREFIX iam: <http://iam.ucdavis.edu/schema#>
PREFIX oap: <http://oapolicy.universityofcalifornia.edu/vocab#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX person: <http://experts.ucdavis.edu/person/>
PREFIX private: <http://experts.ucdavis.edu/private/>
PREFIX purl: <http://purl.org/ontology/bibo/>
PREFIX q: <http://experts.ucdavis.edu/queries/>
PREFIX query: <http://experts.ucdavis.edu/schema/queries/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX ucdrp: <http://experts.ucdavis.edu/schema#>
PREFIX vcard: <http://www.w3.org/2006/vcard/ns#>
PREFIX vivo: <http://vivoweb.org/ontology/core#>
PREFIX work: <http://experts.ucdavis.edu/work/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

insert  { graph experts: {
  ?grant rdfs:label ?title;
         a ?grant_type;
         vivo:sponsorAwardId ?sponsorAwardId;
         vivo:totalAwardAmount ?totalAwardAmount;
         vivo:grandDirectCost ?grantDirectCosts;
         ucdrp:grandIndirectCost ?grantIndirectCosts;
         ucdrp:grantType ?grant_type;
         ucdrp:caoCode ?caoCode;
         vivo:assignedBy ?funding_org;
         vivo:relates ?role,?expert_id;
         vivo:dateTimeInterval ?duration;
         ucdrp:subAwardOf ?super_award;
         .

  ?expert_id vivo:relatedBy ?grant.

  ?expert_role obo:RO_000052 ?expert_id .
  ?role a ?role_type;
        rdfs:label ?role_label;
        vivo:relatedBy ?grant;
        ucdrp:role_person_name ?role_person_name;
        .

  ?duration a ?duration_type;
            vivo:start ?start;
            vivo:end ?end;
            .

  ?start a ?start_type;
         vivo:dateTime           ?start_dateTime;
         vivo:dateTimePrecision  ?start_dateTimePrecision.

  ?end a ?end_type;
       vivo:dateTime           ?end_dateTime;
       vivo:dateTimePrecision  ?end_dateTimePrecision.

  ?funding_org rdfs:label ?funder_label;
               a ?funder_type;
               vivo:assigns ?grant;
               .

  ?super_award vivo:assignedBy ?super_funding_org.
  ?super_funding_org rdfs:label ?super_funder_label;
               a ?super_funder_type;
               vivo:assigns ?grant;
               .


} }
WHERE {
  values ?role_type_ok { vivo:AdminRole vivo:LeaderRole vivo:ResearcherRole
    vivo:CoPrincipalInvestigatorRole vivo:PrincipalInvestigatorRole }

    { SELECT ?grant ?expert_role ?expert_id
    WHERE {
      graph ?private {
        ?grant a vivo:Grant;
               vivo:relates ?expert_role;
               .

        ?expert_role obo:RO_000052 ?expert_id.
      }

      {
        select ?expert_id WHERE {
          graph harvest_oap: {
            ?user oap:experts_person_id ?expert_id ;
            .
          }
        } }
      filter(private:=?private)
    }
  }


  graph private: {
    ?grant a ?grant_type;
           rdfs:label ?title;
           vivo:relates ?role;
           .

    ?role a ?role_type_ok;
          vivo:relatedBy ?grant;
          .

    OPTIONAL {
      ?role ucdrp:role_person_name ?role_person_name;
            .
    }

    OPTIONAL {
      ?role rdfs:label ?role_label.
    }

    OPTIONAL { ?role a ?role_type.}

    OPTIONAL {
      ?grant vivo:sponsorAwardId ?sponsorAwardId.
    }
    OPTIONAL {
      ?grant vivo:grandDirectCost ?grantDirectCosts .
    }
    OPTIONAL {
      ?grant ucdrp:grandIndirectCost ?grantIndirectCosts .
    }
    OPTIONAL {
      ?grant ucdrp:grantType ?grant_type.
    }

    OPTIONAL {
      ?grant ucdrp:caoCode ?caoCode .
    }

    OPTIONAL {
      ?grant vivo:assignedBy ?funding_org.
      ?funding_org rdfs:label ?funder_label;
                   a ?funder_type;
                   .
    }

    OPTIONAL {
      ?grant ucdrp:subAwardOf ?super_award;
             .
      ?super_award vivo:assignedBy ?super_funding_org.

      ?super_funding_org rdfs:label ?super_funder_label;
                         a ?super_funder_type;
                         .
    }

    OPTIONAL {
      ?grant vivo:dateTimeInterval ?duration;
             .
      ?duration a ?duration_type;
                .
      OPTIONAL {
        ?duration vivo:start ?start.
        ?start a  ?start_type;
               vivo:dateTime           ?start_dateTime;
               vivo:dateTimePrecision  ?start_dateTimePrecision.
      }
      OPTIONAL {
        ?duration vivo:end ?end.
        ?end a  ?end_type;
             vivo:dateTime ?end_dateTime;
             vivo:dateTimePrecision  ?end_dateTimePrecision;
             .
      }
    }
  }
}
