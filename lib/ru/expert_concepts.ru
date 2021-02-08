# This only works on the terms already in the experts database, which means you need to run the
# labeling of the publications.
PREFIX experts_iam: <http://experts.ucdavis.edu/iam/>
PREFIX experts_oap: <http://experts.ucdavis.edu/oap/>
PREFIX vivo: <http://vivoweb.org/ontology/core#>
PREFIX ucdrp: <http://experts.ucdavis.edu/schema#>

INSERT { graph experts_oap: {
  ?expert vivo:hasResearchArea ?concept.
  ?concept vivo:researchAreaOf ?expert.
}}
WHERE {
  select ?expert ?concept (count(*) as ?cnt) WHERE {
    graph experts_oap: {
      ?authorship a vivo:Authorship;
                  vivo:relates ?expert;
                  vivo:relates ?publication;
                  .
	    ?publication vivo:hasSubjectArea ?concept.
    }
    graph experts_iam: {
      ?expert a ucdrp:person;
              .
    }
	} GROUP BY ?expert ?concept ?p HAVING (COUNT(*) > 3)
};
