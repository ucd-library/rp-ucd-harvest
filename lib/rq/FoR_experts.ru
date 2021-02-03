PREFIX bibo:  <http://purl.org/ontology/bibo/>
PREFIX cito:  <http://purl.org/spar/cito/>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX experts: <http://experts.ucdavis.edu/>
PREFIX experts_iam: <http://experts.ucdavis.edu/iam/>
PREFIX experts_oap: <http://experts.ucdavis.edu/oap/>
PREFIX experts_pub: <http://experts.ucdavis.edu/pub/>
PREFIX foaf:  <http://xmlns.com/foaf/0.1/>
PREFIX FoR: <http://experts.ucdavis.edu/sub/FoR#>
PREFIX free: <http://experts.ucdavis.edu/sub/free#>
PREFIX iam: <http://experts.ucdavis.edu/iam/schema#>
PREFIX harvest_oap: <http://oapolicy.universityofcalifornia.edu/>
PREFIX oap: <http://oapolicy.universityofcalifornia.edu/vocab#>
PREFIX obo:   <http://purl.obolibrary.org/obo/>
PREFIX orcid: <http://orcid.org/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX scopus: <http://experts.ucdavis.edu/oap/scopus/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX ucd:   <http://experts.ucdavis.edu/schema#>
PREFIX ucdrp: <http://experts.library.ucdavis.edu/individual/>
PREFIX vcard: <http://www.w3.org/2006/vcard/ns#>
PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
PREFIX vivo:  <http://vivoweb.org/ontology/core#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX list: <http://jena.apache.org/ARQ/list#>
PREFIX fo: <http://www.w3.org/1999/XSL/Format#>

INSERT { graph experts_oap: {
#ONSTRUCT {
  ?expert vivo:hasResearchArea ?keyword.
  ?keyword vivo:researchAreaOf ?expert.
}}
WHERE {
  select distinct ?publication ?expert ?scheme ?keyword WHERE {
  bind("for" as ?scheme)
	GRAPH harvest_oap: {
		?publication oap:records/oap:record ?record ;
					 oap:all-labels/oap:keywords/oap:keyword [ oap:field-value ?for ; oap:scheme ?scheme ] .
		#Authors
		?record oap:native/oap:field [ oap:name "authors" ; oap:people/oap:person [ list:index(?pos ?elem) ] ] .
		?elem oap:links/oap:link ?oap_user .

      ?oap_user oap:category "user";
              oap:username ?username;
              .
      bind(IRI(concat(str(ucdrp:),replace(?username,"@ucdavis.edu",""))) as ?expert)
      bind(IRI(concat(str(FoR:),replace(?for," .*",""))) as ?keyword)

	}
}
}
GROUP BY
	?expert
	?keyword
HAVING
	(COUNT(*) > 3)
ORDER BY
	?expert
	DESC(?tCount)
