# This only works on the terms already in the experts database, which means you
# need to run the labeling of the works.
# However, we do only update these where the oap_harvest incidates we should
# do this, which will not always be true.

PREFIX experts_iam: <http://experts.ucdavis.edu/iam/>
PREFIX experts_oap: <http://experts.ucdavis.edu/oap/>
PREFIX harvest_oap: <http://oapolicy.universityofcalifornia.edu/>
PREFIX oap: <http://oapolicy.universityofcalifornia.edu/vocab#>
PREFIX ucdrp: <http://experts.ucdavis.edu/schema#>
PREFIX vivo: <http://vivoweb.org/ontology/core#>

INSERT { graph experts_oap: {
  ?expert vivo:hasResearchArea ?concept.
  ?concept vivo:researchAreaOf ?expert.
}} WHERE {
SELECT ?expert (uri(replace(?keywords,?f,"$1")) as ?concept) WHERE {
  VALUES ?cnt { 0 1 2 3 4 }
  bind(concat("^(?:(?:[^☺]+)☺){",str(?cnt),"}([^☺]+).*") as ?f)
  filter(?cnt<?total_keywords)
   bind(?keywords as ?keyword)
  { SELECT ?expert
           (group_concat(?concept; separator="☺") as ?keywords)
           (count(*) as ?total_keywords) where {
             select ?expert ?concept (count(*) as ?cnt) WHERE {
               graph ?e {
                 ?authorship a vivo:Authorship;
                             vivo:relates ?expert;
                             vivo:relates ?work;
                             .
                 ?work vivo:hasSubjectArea ?concept.
                 ?expert a ucdrp:person.
                 filter(isiri(?expert))
               }
               graph ?h {
                 ?user oap:experts_person_id ?expert .
                 filter not exists {
                   ?user oap:user_supplied_concepts true.
                   }
               }
             } GROUP BY ?expert ?concept order by desc(?cnt)
           } group by ?expert
  }
}};
