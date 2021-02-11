# Add in the Journals seperately, since we may replace this with a call to the
# Elements Database
PREFIX oap: <http://oapolicy.universityofcalifornia.edu/vocab#>
PREFIX oapx: <http://experts.ucdavis.edu/oap/vocab#>
PREFIX cite: <http://citationstyles.org/schema/>
PREFIX bibo: <http://purl.org/ontology/bibo/>
PREFIX vivo: <http://vivoweb.org/ontology/core#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX list: <http://jena.apache.org/ARQ/list#>
PREFIX experts: <http://experts.ucdavis.edu/>
PREFIX experts_oap: <http://experts.ucdavis.edu/oap/>
PREFIX harvest_oap: <http://oapolicy.universityofcalifornia.edu/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX work: <http://experts.ucdavis.edu/work/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX vcard: <http://www.w3.org/2006/vcard/ns#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX venue: <http://experts.ucdavis.edu/venue/>

INSERT {
  GRAPH experts_oap: {
    ?journalURI a bibo:Journal ;
    rdfs:label ?journalTitle ;
    bibo:issn ?issn ;
    bibo:eissn ?eissn.
  }
}
WHERE {
  GRAPH harvest_oap: {
    ?work oap:best_native_record ?native;
    .

    ?native oap:field [ oap:name "journal" ; oap:text ?journalTitle ].
    BIND(REPLACE(REPLACE(LCASE(STR(?journalTitle)), '[^\\w\\d]','-'), '-{2,}' ,'-') AS ?journalIdText)
    OPTIONAL {
      ?native oap:field [ oap:name "eissn" ; oap:text ?eissn ].
    }
    OPTIONAL {
      ?native oap:field [ oap:name "issn" ; oap:text ?issn ].
    }
    BIND(URI(CONCAT(str(venue:), COALESCE(CONCAT("issn:", ?issn), CONCAT("eissn:", ?eissn), CONCAT("journal:", ?journalIdText)))) AS ?journalURI)
    }
};
