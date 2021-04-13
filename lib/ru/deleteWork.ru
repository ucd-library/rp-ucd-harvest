-- Delete work

PREFIX experts: <http://experts.ucdavis.edu/schema#>
WITH <http://experts/>
DELETE {
  	?work ?p ?o .
}
WHERE {
    BIND(<http://experts.ucdavis.edu/work/1525053> as ?work)	
	?work ?p ?o .
};

# Delete Authorships relationship(s)

PREFIX vivo: <http://vivoweb.org/ontology/core#>
PREFIX experts: <http://experts.ucdavis.edu/schema#>
WITH <http://experts/>
DELETE {
	?authorship ?p ?o .
	?s ?p2 ?authorship .
}
WHERE {
    BIND(<http://experts.ucdavis.edu/work/1525053> as ?work)	
	VALUES ?authorship_type {vivo:Authorship experts:authorship}	
  	?authorship a ?authorship_type ;
  				vivo:relates ?work ;
				?p ?o .
	?s ?p2 ?authorship .
};

# Delete Concepts (Work) relationship(s)

PREFIX vivo: <http://vivoweb.org/ontology/core#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX experts: <http://experts.ucdavis.edu/schema#>
WITH <http://experts/>
DELETE {
	?concept vivo:subjectAreaOf ?work.
}
WHERE {
    BIND(<http://experts.ucdavis.edu/work/1525053> as ?work)	
    VALUES ?concept_type {skos:Concept experts:concept}
	?concept a ?concept_type .
			 vivo:subjectAreaOf ?work
};

# Delete DateTimeValues (Work) relationship(s)

PREFIX vivo: <http://vivoweb.org/ontology/core#>
WITH <http://experts/>
DELETE {
	?dtv ?p ?o .
}
WHERE {
    BIND(<http://experts.ucdavis.edu/work/1525053> as ?work)	
	?work vivo:dateTimeValue ?dtv .
	?dtv a vivo:DateTimeValue  ;
		 ? p ?o .
};

# Delete Grants (Work) relationship(s)

PREFIX vivo: <http://vivoweb.org/ontology/core#>
WITH <http://experts/>
DELETE {
	?grant supportedInformationResource ?work .
}
WHERE {
    BIND(<http://experts.ucdavis.edu/work/1525053> as ?work)
	?grant a vivo:Grant .
		   supportedInformationResource ?work .
};

# Delete Journal relationship(s)

PREFIX bibo: <http://purl.org/ontology/bibo/>
PREFIX vivo: <http://vivoweb.org/ontology/core#>
WITH <http://experts/>
DELETE {
	?journal vivo:publicationVenueFor ?work .
}
WHERE {
    BIND(<http://experts.ucdavis.edu/work/1525053> as ?work)
	?journal a bibo:Journal ;
			 vivo:publicationVenueFor ?work .
};
