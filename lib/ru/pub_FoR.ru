# coding: utf-8
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX experts_oap: <http://experts.ucdavis.edu/oap/>
PREFIX FoR: <http://experts.ucdavis.edu/concept/FoR#>
PREFIX free: <http://experts.ucdavis.edu/concept/free#>
PREFIX harvest_oap: <http://oapolicy.universityofcalifornia.edu/>
PREFIX oap: <http://oapolicy.universityofcalifornia.edu/vocab#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX vivo: <http://vivoweb.org/ontology/core#>
PREFIX ucdrp: <http://experts.ucdavis.edu/schema#>

# Add in the Concept Scheme
INSERT { GRAPH experts_oap: {
  FoR: a skos:ConceptScheme;
      dcterms:title "2008 ANZSRC Fields of Research (FoR) classification"@en;
      dcterms:source <https://www.arc.gov.au/grants/grant-application/classification-codes-rfcd-seo-and-anzsic-codes>;
      dcterms:creator "Australian Bureau of Statistics (ABS) and Statistics New Zealand (Statistics NZ)" ;
      dcterms:created "2008-04-22"^^<http://www.w3.org/2001/XMLSchema#date> ;
      dcterms:type "thesaurus" ;
      dcterms:identifier "ISBN 9780642483584" ;
      dcterms:language <http://id.loc.gov/vocabulary/iso639-2/eng>;
      dcterms:license <http://creativecommons.org/licenses/by-sa/3.0/igo/> ;
      dcterms:rights "© Commonwealth of Australia 2008" ;
     dcterms:rights
'''This work is copyright. Apart from any use as permitted under the Copyright Act 1968,
no part may be reproduced by any process without prior written permission
from the Commonwealth. Requests and inquiries concerning reproduction and
rights in this publication should be addressed to The Manager, Intermediary
Management, Australian Bureau of Statistics, Locked Bag 10, Belconnen ACT
2616, by telephone (02) 6252 6998, fax (02) 6252 7102, or email <intermediary.management@abs.gov.au>''' ;
skos:prefLabel "ANZSRC FoR Classification";
skos:hasTopConcept FoR:01,FoR:02,FoR:03,FoR:04,FoR:05,FoR:06,FoR:07,FoR:08,FoR:09,FoR:10,
FoR:11,FoR:12,FoR:13,FoR:14,FoR:15,FoR:16,FoR:17,FoR:18,FoR:19,FoR:20,
FoR:21,FoR:22;
      .
}} WHERE {};

# Now add in all terms
INSERT { GRAPH experts_oap: {
    ?conceptURI a skos:Concept, ucdrp:concept.
    ?conceptURI rdfs:label ?keyword .
}}
WHERE { GRAPH harvest_oap: {
  ?work oap:best_record ?record;
              oap:all-labels/oap:keywords/oap:keyword [ oap:field-value ?keyword ; oap:scheme 'for' ] .
  BIND(URI(CONCAT("http://experts.ucdavis.edu/concept/FoR#", REPLACE(?keyword," .*",""))) AS ?conceptURI)
}};

# Now add the terms to the works.
INSERT { GRAPH experts_oap: {
    ?experts_work_id vivo:hasSubjectArea ?conceptURI .
    ?conceptURI vivo:subjectAreaOf ?experts_work_id .
}}
WHERE { GRAPH ?harvest_graph {
  ?work oap:experts_work_id ?experts_work_id;
               oap:all-labels/oap:keywords/oap:keyword [ oap:field-value ?keyword ; oap:scheme 'for' ] .
}
  GRAPH experts_oap: {
    ?conceptURI rdfs:label ?keyword
  }
}
