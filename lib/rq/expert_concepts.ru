# This only works on the terms already in the experts database, which means you need to run the
# labeling of the publications.
PREFIX experts_oap: <http://experts.ucdavis.edu/oap/>
PREFIX vivo: <http://vivoweb.org/ontology/core#>

INSERT { graph experts_oap: {
  ?expert vivo:hasResearchArea ?concept.
  ?concept vivo:researchAreaOf ?expert.
}}
WHERE {
  select ?expert ?concept (count(*) ?cnt) WHERE {
    GRAPH experts_oap: {
      ?authorship a vivo:Authorship;
                  vivo:relates ?expert;
                  vivo:relates ?publication;
                  .
      ?expert vivo:relatedBy ?authorship .

      ?publication vivo:hasSubjectArea ?concept.
    }
  } GROUP BY ?expert ?concept HAVING (COUNT(*) > 3)
};
