PREFIX oap: <http://oapolicy.universityofcalifornia.edu/vocab#>
PREFIX oapx: <http://experts.ucdavis.edu/oap/vocab#>
PREFIX cite: <http://citationstyles.org/schema/>
PREFIX bibo: <http://purl.org/ontology/bibo/>
PREFIX vivo: <http://vivoweb.org/ontology/core#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX list: <http://jena.apache.org/ARQ/list#>
PREFIX experts: <http://experts.ucdavis.edu/>
PREFIX person: <http://experts.ucdavis.edu/person/>
PREFIX work: <http://experts.ucdavis.edu/work/>
PREFIX harvest_oap: <http://oapolicy.universityofcalifornia.edu/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX vcard: <http://www.w3.org/2006/vcard/ns#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>

# Update the users with their opaque person_ids

INSERT {
	GRAPH harvest_oap: {
		?user oap:experts_person_id ?person_id;
				.
	}
} WHERE {
	GRAPH harvest_oap: {
		?user oap:category "user";
				oap:username ?username;
		.
		bind(md5(replace(?username,"@ucdavis.edu","")) as ?user_id)
		bind(uri(concat(str(person:),?user_id)) as ?person_id)
		filter(isiri(?user))
	}
};


# select the best_record for every publication
# Insert this into the oap_harvest records themselves,
# This is like a materialized view.

INSERT {
GRAPH harvest_oap: {
    ?work oap:best_record ?exemplarRecord ;
    oap:best_native_record ?a_native;
    oap:work_number ?work_number;
    oap:experts_work_id ?experts_work_id;
    .
  }
}
WHERE {
  GRAPH harvest_oap: {
    { select ?work ?exemplarRecord ?a_native ?work_number ?experts_work_id WHERE {
      { select ?work ?exemplarRecord (min(?native) as ?a_native) WHERE {
        ?exemplarRecord oap:native ?native.
        bind(replace(str(?work),str(harvest_oap:),'') as ?pub_id)
        bind(uri(concat(str(work:),?pub_id)) as ?experts_work_id)
        {
          SELECT ?work (MIN(?record) AS ?exemplarRecord) WHERE {
            VALUES (?sourceNameA ?minPriority) {
              ("verified-manual" 1) ("epmc" 2) ("pubmed" 3)  ("scopus" 4)("wos" 5) ("wos-lite" 6)
              ("crossref" 7)  ("dimensions" 8) ("arxiv" 9)("orcid" 10) ("dblp" 11)  ("cinii-english" 12)
              ("repec" 13)  ("figshare" 14)  ("cinii-japanese" 15) ("manual" 16)  ("dspace" 17) }
            ?work oap:category "publication" ;
            oap:records/oap:record ?record .
            ?record oap:source-name  ?sourceNameA
            {
              SELECT
              ?work (MIN(?priority) AS ?minPriority)
              WHERE {
                VALUES (?sourceNameIQ ?priority) {
                  ("verified-manual" 1) ("epmc" 2) ("pubmed" 3)  ("scopus" 4)("wos" 5) ("wos-lite" 6)
                  ("crossref" 7)  ("dimensions" 8) ("arxiv" 9)("orcid" 10) ("dblp" 11)  ("cinii-english" 12)
                  ("repec" 13)  ("figshare" 14)  ("cinii-japanese" 15) ("manual" 16)  ("dspace" 17) }
                ?work oap:category "publication" ;
                oap:records/oap:record/oap:source-name ?sourceNameIQ
              } GROUP BY ?work }
          } GROUP BY ?work }
      } GROUP BY ?work ?exemplarRecord }
      bind(replace(str(?work),str(harvest_oap:),'') as ?work_number)
      bind(uri(concat(str(work:),?work_number)) as ?experts_work_id)
    }}
  }
}
