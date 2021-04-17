# Delete Person

WITH <http://experts/>
DELETE {
  	?person ?p ?o .
}
WHERE {
    BIND(<http://experts.ucdavis.edu/person/4dabbfde29b422729d5574338bb02178> as ?person)
  	?person ?p ?o .
};

# Delete Grants (Person) relationship(s)

PREFIX vivo: <http://vivoweb.org/ontology/core#>
WITH <http://experts/>
DELETE {
	?grant vivo:relates ?person
}
WHERE {
    BIND(<http://experts.ucdavis.edu/person/4dabbfde29b422729d5574338bb02178> as ?person)
	?grant a vivo:Grant ;
		   vivo:relates ?person .
};

# Delete Individual and their vcard, etc. relationship(s)

PREFIX vcard: <http://www.w3.org/2006/vcard/ns#>
prefix obo: <http://purl.obolibrary.org/obo/>
WITH <http://experts/>
DELETE {
	?individual ?p ?o .
	?o ?p2 ?o2 .
}
WHERE {
    BIND(<http://experts.ucdavis.edu/person/4dabbfde29b422729d5574338bb02178> as ?person)
	?individual a vcard:Individual	
	FILTER NOT EXISTS {
		?person obo:ARG_20000028 ?individual .
	}
	?individual ?p ?o .
	OPTIONAL {
		?o ?p2 ?o2 .
	}
};

# Delete Concepts tied to expert

PREFIX vivo: <http://vivoweb.org/ontology/core#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX experts: <http://experts.ucdavis.edu/schema#>
WITH <http://experts/>
DELETE {
	?concept vivo:researchAreaOf ?person .
}
WHERE {
    BIND(<http://experts.ucdavis.edu/person/4dabbfde29b422729d5574338bb02178> as ?person)
	VALUES ?concept_type {skos:Concept experts:concept}
	?concept a ?concept_type ;
			 vivo:researchAreaOf ?person .
	}
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
    BIND(<http://experts.ucdavis.edu/person/4dabbfde29b422729d5574338bb02178> as ?person)
	VALUES ?authorship_type {vivo:Authorship experts:authorship}	       
  	?authorship a ?authorship_type ;
  				vivo:relates ?person ;
				?p ?o .
	?s ?p2 ?authorship .				
};

# Commenting out as a better approach might be to create a generalized orphan-finding DELETE statement. Per Quinn, an orphan is anything not a URI 
# # Delete Works
# 
# PREFIX bibo: <http://purl.org/ontology/bibo/>
# PREFIX vivo: <http://vivoweb.org/ontology/core#>
# PREFIX experts: <http://experts.ucdavis.edu/schema#>
# WITH <http://experts/>
# DELETE {
# 	?work ?p ?o .
# }
# WHERE {
# 	# Once the VIVO ontology is in place we can replace "?work a ?work_type" with 
# 	# "?work a bibo:Document" and remove the inline data (VALUES).
#     BIND(<http://experts.ucdavis.edu/person/4dabbfde29b422729d5574338bb02178> as ?person)	
# 	VALUES ?work_type {bibo:Book bibo:Chapter vivo:ConferencePaper bibo:AcademicArticle experts:work}
# 	?work a ?work_type .
# 	FILTER NOT EXISTS {
# 		?person vivo:relatedBy ?authorship .
# 		?authorship vivo:relates ?work .
# 	}
# 	?work ?p ?o .
# };
# 
# # Delete Concepts (Work)
# 
# PREFIX vivo: <http://vivoweb.org/ontology/core#>
# prefix skos: <http://www.w3.org/2004/02/skos/core#>
# PREFIX experts: <http://experts.ucdavis.edu/schema#>
# WITH <http://experts/>
# DELETE {
# 	?concept ?p ?o .
# }
# WHERE {
#     BIND(<http://experts.ucdavis.edu/person/4dabbfde29b422729d5574338bb02178> as ?person)
#     VALUES ?concept_type {skos:Concept experts:concept}
# 	?concept a ?concept_type .
# 	FILTER NOT EXISTS {
# 		?person vivo:relatedBy ?authorship .
# 		?authorship vivo:relates ?work .
# 		?work vivo:hasSubjectArea ?concept .
# 	}
# 	?concept ?p ?o .
# };
# 
# # Delete DateTimeValues (Work)
# 
# PREFIX vivo: <http://vivoweb.org/ontology/core#>
# WITH <http://experts/>
# DELETE {
# 	?dtv ?p ?o .
# }
# WHERE {
#     BIND(<http://experts.ucdavis.edu/person/4dabbfde29b422729d5574338bb02178> as ?person)
# 	?dtv a vivo:DateTimeValue .
# 	FILTER NOT EXISTS {
# 		?person vivo:relatedBy ?authorship .
# 		?authorship vivo:relates ?work .
# 		?work vivo:dateTimeValue ?dtv .
# 	}
# 	?dtv ?p ?o .
# };
# 
# # Delete Grants (Work)
# 
# PREFIX vivo: <http://vivoweb.org/ontology/core#>
# WITH <http://experts/>
# DELETE {
# 	?grant ?p ?o .
# }
# WHERE {
#     BIND(<http://experts.ucdavis.edu/person/4dabbfde29b422729d5574338bb02178> as ?person)
# 	?grant a vivo:Grant .
# 	FILTER NOT EXISTS {
# 		?person vivo:relatedBy ?authorship .
# 		?authorship vivo:relates ?work .
# 		?work vivo:informationResourceSupportedBy ?grant .
# 	}
# 	?grant ?p ?o .
# };
# 
# # Delete Journals
# 
# PREFIX bibo: <http://purl.org/ontology/bibo/>
# PREFIX vivo: <http://vivoweb.org/ontology/core#>
# WITH <http://experts/>
# DELETE {
# 	?journal ?p ?o .
# }
# WHERE {
#     BIND(<http://experts.ucdavis.edu/person/4dabbfde29b422729d5574338bb02178> as ?person)
# 	?journal a bibo:Journal .
# 	FILTER NOT EXISTS {
# 		?person vivo:relatedBy ?authorship .
# 		?authorship vivo:relates ?work .
# 		?work vivo:hasPublicationVenue ?journal
# 	}
# 	?journal ?p ?o .
# };
