# select the best_record for every publication
# Insert this into the oap_harvest records themselves,
# This is like a materialized view.
PREFIX oap: <http://oapolicy.universityofcalifornia.edu/vocab#>
PREFIX oapx: <http://experts.ucdavis.edu/oap/vocab#>
PREFIX cite: <http://citationstyles.org/schema/>
PREFIX bibo: <http://purl.org/ontology/bibo/>
PREFIX vivo: <http://vivoweb.org/ontology/core#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX list: <http://jena.apache.org/ARQ/list#>
PREFIX experts: <http://experts.ucdavis.edu/>
PREFIX experts_oap: <http://experts.ucdavis.edu/oap/>
PREFIX publication: <http://experts.ucdavis.edu/publication/>
PREFIX harvest_oap: <http://oapolicy.universityofcalifornia.edu/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX vcard: <http://www.w3.org/2006/vcard/ns#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>

INSERT {
GRAPH harvest_oap: {
    ?publication oap:best_record ?exemplarRecord ;
    oap:best_native_record ?a_native;
    oap:publication_number ?publication_number;
    oap:experts_publication_id ?experts_publication_id;
    .
  }
}
WHERE {
  GRAPH harvest_oap: {
    { select ?publication ?exemplarRecord ?a_native ?publication_number ?experts_publication_id WHERE {
      { select ?publication ?exemplarRecord (min(?native) as ?a_native) WHERE {
        ?exemplarRecord oap:native ?native.
        bind(replace(str(?publication),str(harvest_oap:),'') as ?pub_id)
        bind(uri(concat(str(publication:),?pub_id)) as ?experts_publication_id)
        {
          SELECT ?publication (MIN(?record) AS ?exemplarRecord) WHERE {
            VALUES (?sourceNameA ?minPriority) {
              ("verified-manual" 1) ("epmc" 2) ("pubmed" 3)  ("scopus" 4)("wos" 5) ("wos-lite" 6)
              ("crossref" 7)  ("dimensions" 8) ("arxiv" 9)("orcid" 10) ("dblp" 11)  ("cinii-english" 12)
              ("repec" 13)  ("figshare" 14)  ("cinii-japanese" 15) ("manual" 16)  ("dspace" 17) }
            ?publication oap:category "publication" ;
            oap:records/oap:record ?record .
            ?record oap:source-name  ?sourceNameA
            {
              SELECT
              ?publication (MIN(?priority) AS ?minPriority)
              WHERE {
                VALUES (?sourceNameIQ ?priority) {
                  ("verified-manual" 1) ("epmc" 2) ("pubmed" 3)  ("scopus" 4)("wos" 5) ("wos-lite" 6)
                  ("crossref" 7)  ("dimensions" 8) ("arxiv" 9)("orcid" 10) ("dblp" 11)  ("cinii-english" 12)
                  ("repec" 13)  ("figshare" 14)  ("cinii-japanese" 15) ("manual" 16)  ("dspace" 17) }
                ?publication oap:category "publication" ;
                oap:records/oap:record/oap:source-name ?sourceNameIQ
              } GROUP BY ?publication }
          } GROUP BY ?publication }
      } GROUP BY ?publication ?exemplarRecord }
      bind(replace(str(?publication),str(harvest_oap:),'') as ?publication_number)
      bind(uri(concat(str(publication:),?publication_number)) as ?experts_publication_id)
    }}
  }
}
