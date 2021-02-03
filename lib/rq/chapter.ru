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
		?publication a bibo:Chapter ;
				rdfs:label ?title ;
				bibo:volume ?volume ;
				bibo:doi ?doi ;
				bibo:pageStart ?beginPage ;
				bibo:pageEnd ?endPage ;
				bibo:isbn10 ?isbn10 ;
				bibo:isbn13 ?isbn13 ;
				bibo:uri ?pubExternalURL ;
				bibo:status ?vivoStatus ;
				vivo:relatedBy _:authorship .
		_:authorship a vivo:Authorship ;
					 vivo:rank ?authorRank ;
					 vivo:relates ?personURI ;
					 vivo:relates ?publication ;
					 vivo:relates [ a vcard:Individual ;
									vivo:relatedBy _:authorship ;
									vcard:hasName [ a vcard:Name ;
													vcard:last_name ?authorLastName ;
													vcard:first_name ?authorFirstName ;
												  ] ;
								  ] .
	}
}
WHERE {
	GRAPH harvest_oap: {
		?publication oap:records/oap:record ?exemplarRecord .

		#Authors
		?exemplarRecord oap:native/oap:field [ oap:name "authors" ; oap:people/oap:person [ list:index(?pos ?elem) ] ] .
		?elem oap:last-name ?authorLastName ;
			  oap:first-names ?authorFirstName .
		BIND(?pos+1 AS ?authorRank)
		#Link to UCD user for future wire-up to Person
        OPTIONAL {
        	?elem oap:links/oap:link ?userLink.
      		?userLink  oap:username ?username .
      		BIND(URI(CONCAT(STR("http://experts.ucdavis.edu/"),STRBEFORE(?username,"@"))) AS ?personURI)
      	}

		?exemplarRecord oap:native/oap:field [ oap:name "title" ; oap:text ?title ] .
		OPTIONAL {
			?exemplarRecord oap:native/oap:field [ oap:name "volume" ; oap:text ?volume ].
		}
		OPTIONAL {
			?exemplarRecord oap:native/oap:field [ oap:name "doi" ; oap:text ?doi ].
		}
		OPTIONAL {
			?exemplarRecord oap:native/oap:field [ oap:name "pagination" ; oap:pagination [ oap:begin-page ?beginPage ; oap:end-page ?endPage ] ].
		}
		OPTIONAL {
			?exemplarRecord oap:native/oap:field [ oap:name "isbn-10" ; oap:text ?isbn10 ].
		}
		OPTIONAL {
			?exemplarRecord oap:native/oap:field [ oap:name "isbn-13" ; oap:text ?isbn13 ].
		}
		OPTIONAL {
			VALUES ?pubExternalURLField {'author-url' 'public-url' }
			?exemplarRecord oap:native/oap:field [ oap:name ?pubExternalURLField ; oap:text ?pubExternalURL ].
		}
		OPTIONAL {
			VALUES (?status ?vivoStatus) { ( "Published" bibo:published ) ( "Published online" bibo:published ) ( "Accepted" bibo:accepted ) }
			?exemplarRecord oap:native/oap:field [ oap:name "publication-status" ; oap:text ?status ]
		}
		{
		SELECT
			?publication (MIN(?record) AS ?exemplarRecord)
		WHERE {
			# Map the priority back to its source-name
			VALUES (?sourceNameA ?minPriority) {
				("verified-manual" 1)
				("epmc" 2)
				("pubmed" 3)
				("scopus" 4)
				("wos" 5)
				("wos-lite" 6)
				("crossref" 7)
				("dimensions" 8)
				("arxiv" 9)
				("orcid" 10)
				("dblp" 11)
				("cinii-english" 12)
				("repec" 13)
				("figshare" 14)
				("cinii-japanese" 15)
				("manual" 16)
				("dspace" 17)
			}
			?publication oap:category "publication" ;
						 oap:type "chapter" ;
						 oap:records/oap:record ?record .
			?record oap:source-name  ?sourceNameA
			{
			SELECT
				?publication (MIN(?priority) AS ?minPriority)
			WHERE {
				# Map the source-name to its priority
				VALUES (?sourceNameIQ ?priority) {
					("verified-manual" 1)
					("epmc" 2)
					("pubmed" 3)
					("scopus" 4)
					("wos" 5)
					("wos-lite" 6)
					("crossref" 7)
					("dimensions" 8)
					("arxiv" 9)
					("orcid" 10)
					("dblp" 11)
					("cinii-english" 12)
					("repec" 13)
					("figshare" 14)
					("cinii-japanese" 15)
					("manual" 16)
					("dspace" 17)
				}
				?publication oap:category "publication" ;
							 oap:type "chapter" ;
							 oap:records/oap:record/oap:source-name ?sourceNameIQ
			  }
			  GROUP BY
				?publication
			}
		}
		GROUP BY
			?publication
		}
	}
}
