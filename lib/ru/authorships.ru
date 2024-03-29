# Next Insert Authors.  Do this seperately, so we don't needlessly check
# work level values

PREFIX authorship: <http://experts.ucdavis.edu/authorship/>
PREFIX bibo: <http://purl.org/ontology/bibo/>
PREFIX cite: <http://citationstyles.org/schema/>
PREFIX experts: <http://experts.ucdavis.edu/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX harvest_oap: <http://oapolicy.universityofcalifornia.edu/>
PREFIX list: <http://jena.apache.org/ARQ/list#>
PREFIX oap: <http://oapolicy.universityofcalifornia.edu/vocab#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX ucdrp: <http://experts.ucdavis.edu/schema#>
PREFIX vcard: <http://www.w3.org/2006/vcard/ns#>
PREFIX venue: <http://experts.ucdavis.edu/venue/>
PREFIX vivo: <http://vivoweb.org/ontology/core#>
PREFIX work: <http://experts.ucdavis.edu/work/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

# Build the vcard authorships (For any author) from our best record only
INSERT {
  GRAPH experts: {
    ?authorship a vivo:Authorship,ucdrp:authorship ;
    vivo:rank ?authorRank ;
    vivo:relates ?experts_work_id ;
    vivo:relates ?authorship_vcard;
    .

    ?authorship_vcard a vcard:Individual ;
    vivo:relatedBy ?vcard ;
    vcard:hasName ?authorship_vcard_name;
    .

    ?authorship_vcard_name  a vcard:Name ;
    vcard:familyName ?authorLastName ;
    vcard:givenName ?authorFirstName ;
    .

		?experts_work_id vivo:relatedBy ?authorship.
  }
}
WHERE { GRAPH harvest_oap: {
  ?work oap:best_native_record ?native;
        oap:experts_work_id ?experts_work_id;
        oap:work_number ?pub_id;
        .

  ?native oap:field [ oap:name "authors" ; oap:people/oap:person [ list:index(?pos ?elem) ] ] .
  BIND(?pos+1 AS ?authorRank)
	BIND(uri(concat(replace(str(?experts_work_id),str(work:),str(authorship:)),"-",str(?authorRank))) as ?authorship)
	BIND(uri(concat(str(?authorship),"#vcard")) as ?authorship_vcard)
	BIND(uri(concat(str(?authorship_vcard),"-name")) as ?authorship_vcard_name)


	OPTIONAL {
		?elem oap:last-name ?authorLastName .
  }
  OPTIONAL {
    ?elem oap:first-names ?authorFirstName .
	}
}};

# Next Add-in record links for our best record, using ranks
INSERT {
  GRAPH experts: {
    ?authorship a vivo:Authorship,ucdrp:authorship ;
    vivo:rank ?authorRank ;
    vivo:relates ?experts_work_id ;
    vivo:relates ?personURI ;
    vivo:favorite ?favorite;
    .

		?personURI vivo:relatedBy ?authorship.
    ?experts_work_id vivo:relatedBy ?authorship;
  }
}
WHERE { GRAPH harvest_oap: {
  ?work oap:best_native_record ?native;
        oap:experts_work_id ?experts_work_id;
        oap:work_number ?pub_id;
        .

  ?native oap:field [ oap:name "authors" ; oap:people/oap:person [ list:index(?pos ?elem) ] ] .
  BIND(?pos+1 AS ?authorRank)
	BIND(uri(concat(replace(str(?experts_work_id),str(work:),str(authorship:)),"-",str(?authorRank))) as ?authorship)
  ?elem oap:links/oap:link ?userLink.
  bind(replace(str(?userLink),str(harvest_oap:),'') as ?user_id)
  [] oap:type "publication-user-authorship";
     oap:is-visible "true";
     oap:related [ oap:category "publication";
                   oap:id ?pub_id;
                 ];
  oap:related [ oap:category "user";
                oap:id ?user_id;
              ];
  oap:is-favourite ?favorite;
  .
  ?userLink  oap:username ?username .
  BIND(URI(CONCAT(STR("http://experts.ucdavis.edu/person/"),md5(STRBEFORE(?username,"@")))) AS ?personURI)
}};


# Next look at *every* native record for links to OAPOLICY records.  We can't use rank
# since the ranks aren't always the same.
INSERT {
  GRAPH experts: {
    ?authorship a vivo:Authorship,ucdrp:authorship ;
    vivo:relates ?experts_work_id ;
    vivo:relates ?personURI ;
    .
		?personURI vivo:relatedBy ?authorship.
    ?experts_work_id vivo:relatedBy ?authorship;
  }
}
WHERE { GRAPH harvest_oap: {
  ?work oap:records/oap:record/oap:native ?native;
        oap:experts_work_id ?experts_work_id;
        oap:work_number ?pub_id;
        .
  ?native oap:field [ oap:name "authors" ; oap:people/oap:person [ list:index(?pos ?elem) ] ] .

  ?elem oap:links/oap:link ?userLink.
  bind(replace(str(?userLink),str(harvest_oap:),'') as ?user_id)

  [] oap:type "publication-user-authorship";
     oap:is-visible "true";
     oap:related [ oap:category "publication";
                   oap:id ?pub_id;
                 ];
  oap:related [ oap:category "user";
                oap:id ?user_id;
              ];
  oap:is-favourite ?favorite;
  .
  ?userLink  oap:username ?username .
  BIND(URI(CONCAT(STR("http://experts.ucdavis.edu/person/"),md5(STRBEFORE(?username,"@")))) AS ?personURI)

  BIND(uri(concat(replace(str(?experts_work_id),str(work:),str(authorship:)),'-',md5(STRBEFORE(?username,"@")))) as ?authorship)

  filter NOT EXISTS {
    GRAPH experts: {
      [] a vivo:Authorship;
         vivo:relates ?personURI;
         vivo:relates ?experts_work_id;
         .
    }
  }

}};

# Additionally, we need to add relationships that are not added by CDL elements.
# For these, we don't know exactly what author is being assigned to this relationship,
#
INSERT {
  GRAPH experts: {
    ?authorship a vivo:Authorship,ucdrp:authorship ;
    vivo:relates ?personURI ;
    vivo:relates ?experts_work_id ;
    vivo:favorite ?favorite;
    .

	  ?experts_work_id vivo:relatedBy ?authorship.
		?personURI vivo:relatedBy ?authorship.
  }
}
WHERE { GRAPH harvest_oap: {
  ?work oap:experts_work_id ?experts_work_id;
        oap:work_number ?pub_id;
        .

  [] oap:type "publication-user-authorship";
     oap:is-visible "true";
     oap:related [ oap:category "publication";
                   oap:id ?pub_id;
                 ];
  oap:related [ oap:category "user";
                oap:id ?user_id;
              ];
  oap:is-favourite ?favorite;
  .

  bind(uri(concat(str(harvest_oap:),?user_id)) as ?userLink)
  ?userLink  oap:username ?username .
  BIND(URI(CONCAT(STR("http://experts.ucdavis.edu/person/"),md5(STRBEFORE(?username,"@")))) AS ?personURI)

  BIND(uri(concat(replace(str(?experts_work_id),str(work:),str(authorship:)),'-',md5(STRBEFORE(?username,"@")))) as ?authorship)

  filter NOT EXISTS {
    GRAPH experts: {
      [] a vivo:Authorship;
           vivo:relates ?personURI;
           vivo:relates ?experts_work_id;
           .
    }
  }
}};
