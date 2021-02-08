PREFIX oap: <http://oapolicy.universityofcalifornia.edu/vocab#>
PREFIX oapx: <http://experts.ucdavis.edu/oap/vocab#>
PREFIX cite: <http://citationstyles.org/schema/>
PREFIX bibo: <http://purl.org/ontology/bibo/>
PREFIX vivo: <http://vivoweb.org/ontology/core#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX list: <http://jena.apache.org/ARQ/list#>
PREFIX experts: <http://experts.ucdavis.edu/>
PREFIX experts_oap: <http://experts.ucdavis.edu/oap/>
PREFIX experts_pubs: <http://experts.ucdavis.edu/pubs/>
PREFIX harvest_oap: <http://oapolicy.universityofcalifornia.edu/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX vcard: <http://www.w3.org/2006/vcard/ns#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>

INSERT {
	GRAPH experts_oap: {
		?publication vivo:hasfreetextKeyword ?keyword
	}
}
WHERE {
	GRAPH harvest_oap: {
		?publication oap:best_native_record ?native;
               oap:experts_id ?experts_id;
    .
		{
			{
				?native oap:field  [ oap:display-name  "Keywords" ; oap:keywords/oap:keyword ?keyword ]
				FILTER(!ISBLANK(?keyword))
			}
		  	UNION
			{
				?native oap:field  [ oap:display-name  "Keywords" ; oap:keywords/oap:keyword/oap:field-value ?keyword ]
			}
		}
        }
}
