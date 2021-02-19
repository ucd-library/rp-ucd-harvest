# Based on https://aws.amazon.com/blogs/database/write-a-cascading-delete-in-sparql/, 
# would like to have done something like the following, which is more flexible in the 
# predicates it covers.
# 
# PREFIX vivo: <http://vivoweb.org/ontology/core#>
# PREFIX ex: <http://www.example.org/>
# PREFIX vcard: <http://www.w3.org/2006/vcard/ns#>
# PREFIX bibo: <http://purl.org/ontology/bibo/>
# WITH <http://deletetest/>
# DELETE {
# 	?s ?p ?o
# }  
# WHERE {
#	# The URI of the Person to be deleted
# 	BIND(ex:saulPerson AS ?person)
# 	?person (vivo:relatedBy | vivo:relates | vcard:hasName)* ?o .
#   ?s ?p ?o .
# }

# Delete Person and Authorship(s)

PREFIX ex: <http://www.example.org/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX vivo: <http://vivoweb.org/ontology/core#>
PREFIX vcard: <http://www.w3.org/2006/vcard/ns#>
PREFIX bibo: <http://purl.org/ontology/bibo/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
WITH <http://deletetest/>
DELETE {
	?person a foaf:Person ;
       vivo:relatedBy ?authorship .
    ?authorship a vivo:Authorship ;
                vivo:relates ?person ;
                vivo:relates ?individual ;
                vivo:relates ?work .
    ?work vivo:relatedBy ?authorship .                    
    ?individual a vcard:Individual ;
                vcard:hasName ?individualName .
    ?individualName a vcard:Name ; 
                    vcard:last_name ?ln ; 
                    vcard:first_name ?fn .
    ?work vivo:relatedBy ?authorship .                    
}
WHERE {
	# The URI of the Person to be deleted
	BIND(ex:saulPerson AS ?person)
	?person a foaf:Person ;
	   vivo:relatedBy ?authorship .
	?authorship a vivo:Authorship ;
				vivo:relates ?person ;
				vivo:relates ?individual ;
				vivo:relates ?work .
	?work vivo:relatedBy ?authorship .
	?individual a vcard:Individual ;
				vcard:hasName ?individualName .
	?individualName a vcard:Name ; 
					vcard:last_name ?ln ; 
					vcard:first_name ?fn .

};

# Delete newly-orphaned works

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX ex: <http://www.example.org/>
PREFIX bibo: <http://purl.org/ontology/bibo/>
PREFIX vivo: <http://vivoweb.org/ontology/core#>
WITH <http://deletetest/>
DELETE {
	?work ?p ?o .
	?s ?p2 ?work .
}
WHERE {
	VALUES ?work_type {bibo:Book bibo:Chapter vivo:ConferencePaper bibo:AcademicArticle}
	?work a ?work_type 
	FILTER NOT EXISTS {
		?work vivo:relatedBy ?authorship . 
		?authorship a vivo:Authorship 
	}
	?work ?p ?o .
	OPTIONAL {
		?s ?p2 ?work
	}
}

# ...and so on