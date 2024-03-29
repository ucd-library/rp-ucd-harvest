PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX experts: <http://experts.ucdavis.edu/>
PREFIX FoR: <http://experts.ucdavis.edu/concept/FoR/>
PREFIX free: <http://experts.ucdavis.edu/concept/free/>
PREFIX harvest_oap: <http://oapolicy.universityofcalifornia.edu/>
PREFIX oap: <http://oapolicy.universityofcalifornia.edu/vocab#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX ucdrp: <http://experts.ucdavis.edu/schema#>
PREFIX vivo: <http://vivoweb.org/ontology/core#>
PREFIX experts: <http://experts.ucdavis.edu/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

# Add in the ConceptScheme;
INSERT { GRAPH experts: {
  free: a skos:ConceptScheme;
      dcterms:title "Free Text Terms"@en;
      dcterms:creator "UC Davis Library" ;
      dcterms:type "wordlist" ;
      dcterms:language "en" ;
      skos:prefLabel "Free Text Terms";
    .
}} WHERE{};

INSERT { GRAPH experts: {
  ?keyword a skos:Concept, ucdrp:concept ;
    skos:prefLabel ?term;
    rdfs:label ?term;
    oap:scheme ?scheme;
    skos:inScheme free: ;
#	  ucdrp:lastModifiedDateTime ?lastModifiedDateTime ;
#	  ucdrp:insertionDateTime ?insertionDateTime;
    .

  ?experts_work_id vivo:hasSubjectArea ?keyword.
  ?keyword vivo:subjectAreaOf ?experts_work_id.

}}
WHERE { GRAPH harvest_oap: {
  ?work oap:experts_work_id ?experts_work_id ;
     	oap:all-labels/oap:keywords/oap:keyword [ oap:field-value ?term ; oap:scheme ?scheme ] ;
		oap:last-modified-when ?lastModifiedWhen .
	BIND(xsd:dateTime(?lastModifiedWhen) AS ?lastModifiedDateTime)
	BIND(NOW() as ?insertionDateTime)
	bind(IRI(concat(str(free:),md5(lcase(?term)))) as ?keyword)
#	filter(?scheme != "for")
}};
