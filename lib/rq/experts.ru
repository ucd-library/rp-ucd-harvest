PREFIX bibo: <http://purl.org/ontology/bibo/>
PREFIX cite: <http://citationstyles.org/schema/>
PREFIX experts: <http://experts.ucdavis.edu/>
PREFIX experts_oap: <http://experts.ucdavis.edu/oap/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX harvest_oap: <http://oapolicy.universityofcalifornia.edu/>
PREFIX list: <http://jena.apache.org/ARQ/list#>
PREFIX oap: <http://oapolicy.universityofcalifornia.edu/vocab#>
PREFIX oapx: <http://experts.ucdavis.edu/oap/vocab#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX vcard: <http://www.w3.org/2006/vcard/ns#>
PREFIX vivo: <http://vivoweb.org/ontology/core#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

# First, Insert citation BIBO stuff
INSERT {
	GRAPH experts_oap: {
		?experts_id a ?bibo_type ;
		rdfs:label ?title ;
    bibo:pageStart ?beginPage ;
		bibo:pageEnd ?endPage ;
    bibo:status ?vivoStatus;
    .
	}
}
WHERE { GRAPH harvest_oap: {
  VALUES(?oap_type ?bibo_type){
    ("book" bibo:Book)
    ("chapter" bibo:Chapter)
    ("conference" vivo:ConferencePaper)
    ("journal-article" bibo:AcademicArticle)
  }

	?publication oap:best_native_record ?native;
	oap:type ?oap_type ;
  oap:experts_id ?experts_id;
  oap:publication_number ?pub_id;
  .

	?native oap:field [ oap:name "title" ; oap:text ?title ] .

  OPTIONAL {
		?native oap:field [ oap:name "pagination" ; oap:pagination [ oap:begin-page ?beginPage ; oap:end-page ?endPage ] ].
	}

	OPTIONAL {
		VALUES (?status ?vivoStatus) { ( "Published" bibo:published ) ( "Published online" bibo:published ) ( "Accepted" bibo:accepted ) }
		?exemplarRecord oap:native/oap:field [ oap:name "publication-status" ; oap:text ?status ]
	}

}};

# Now insert optional bibo entries
INSERT {
	GRAPH experts_oap: {
	  ?experts_id ?bibo_predicate ?field_text.
	}
}
WHERE {
	GRAPH harvest_oap: {
		?publication oap:best_native_record ?native;
               oap:experts_id ?experts_id;
    .

    VALUES(?field_name ?bibo_predicate) {
      ("abstract" bibo:abstract)
      ("author-url" bibo:uri)
      ("doi" bibo:doi)
      ("isbn-10" bibo:isbn10)
      ("isbn-13" bibo:isbn13)
      ("issue" bibo:issue)
      ("journal" bibo:journal)
      ("number" bibo:number)
      ("publish-url" bibo:uri)
      ("volume" bibo:volume)
      }
    #      ("",bibo:)

			?native oap:field [ oap:name ?field_name ; oap:text ?field_text ].
}};

# Insert the Publication Date in VIVO format.
INSERT {
	GRAPH experts_oap: {
		?experts_id vivo:dateTimeValue [ a vivo:DateTimeValue ; vivo:dateTime ?publicationDateTime ;  vivo:dateTimePrecision ?dateTimePrecision ]  .
		?dateTimePrecision a vivo:DateTimePrecision .
	}
}
WHERE {
	GRAPH harvest_oap: {
		?publication oap:best_native_record ?native;
               oap:experts_id ?experts_id;
    .

    {
	  ?native oap:field [ oap:name "publication-date" ; oap:date ?publicationDate ].
		}
		UNION
		{
			?native oap:field [ oap:name "online-publication-date" ; oap:date ?publicationDate ].
		}
		?publicationDate oap:year ?publicationDateYear
		BIND(vivo:yearPrecision AS ?yearPrecision)
		OPTIONAL {
			?publicationDate oap:month ?publicationDateMonthRaw
			BIND(IF(xsd:integer(?publicationDateMonthRaw) < 10, CONCAT("0", ?publicationDateMonthRaw), ?publicationDateMonthRaw) AS ?publicationDateMonth)
			BIND(vivo:yearMonthPrecision AS ?yearMonthPrecision)
			OPTIONAL {
				?publicationDate oap:day ?publicationDateDayRaw
				BIND(IF(xsd:integer(?publicationDateDayRaw) < 10, CONCAT("0", ?publicationDateDayRaw), ?publicationDateDayRaw) AS ?publicationDateDay)
				BIND(vivo:yearMonthDayPrecision AS ?yearMonthDayPrecision)
			}
		}
    	BIND(xsd:dateTime(CONCAT(?publicationDateYear, "-", COALESCE(?publicationDateMonth, "01"), "-", COALESCE(?publicationDateDay, "01"), "T00:00:00")) AS ?publicationDateTime)
    	BIND(COALESCE(?yearMonthDayPrecision, ?yearMonthPrecision, ?yearPrecision) AS ?dateTimePrecision)
}};

# Next Insert Auuthors.  Do this seperately, so we don't needlessly check
# publication level values

INSERT {
	GRAPH experts_oap: {
		?experts_id vivo:relatedBy _:authorship.
		_:authorship a vivo:Authorship ;
		vivo:rank ?authorRank ;
		vivo:relates ?personURI ;
		vivo:relates ?experts_id ;
    vivo:favorite ?favorite;
		vivo:relates [ a vcard:Individual ;
									 vivo:relatedBy _:authorship ;
									 vcard:hasName [ a vcard:Name ;
													         vcard:last_name ?authorLastName ;
													         vcard:first_name ?authorFirstName ;
												         ] ;
								 ] .
	}
}
WHERE { GRAPH harvest_oap: {
	?publication oap:best_native_record ?native;
              oap:experts_id ?experts_id;
             oap:publication_number ?pub_id;
  .

	?native oap:field [ oap:name "authors" ; oap:people/oap:person [ list:index(?pos ?elem) ] ] .
	?elem oap:last-name ?authorLastName ;
	oap:first-names ?authorFirstName .
	BIND(?pos+1 AS ?authorRank)

  OPTIONAL {
    ?elem oap:links/oap:link ?userLink.

    bind(replace(str(?userLink),str(harvest_oap:),'') as ?user_id)

    [] oap:type "publication-user-authorship";
       oap:is-visible "true";
       oap:related [ oap:category "publication";
                     oap:id ?pub_id;
                   ];
    oap:related [ oap:category "user";
                  oap:id ?user_id;
                ];
    oap:is-favourite ?favorite;
    .
    ?userLink  oap:username ?username .
    BIND(URI(CONCAT(STR("http://experts.ucdavis.edu/"),STRBEFORE(?username,"@"))) AS ?personURI)
  }
}};

# If it appeared in a journal, identify that relationship
# the JournalURI calculation needs match the journal creation step
INSERT {
	GRAPH experts_oap: {
	  ?experts_id vivo:hasPublicationVenue ?journalURI .
    ?journalURI vivo:publicationVenueFor ?experts_id .
	}
}
WHERE {
	GRAPH harvest_oap: {
		?publication oap:best_native_record ?native;
               oap:experts_id ?experts_id;
    .

		?native oap:field [ oap:name "journal" ; oap:text ?journalTitle ].
		BIND(REPLACE(REPLACE(LCASE(STR(?journalTitle)), '[^\\w\\d]','-'), '-{2,}' ,'-') AS ?journalIdText)
    OPTIONAL {
			?native oap:field [ oap:name "eissn" ; oap:text ?eissn ].
		}
		OPTIONAL {
			?native oap:field [ oap:name "issn" ; oap:text ?issn ].
		}
		BIND(URI(CONCAT(str(experts_pub:), COALESCE(CONCAT("issn:", ?issn), CONCAT("issn:", ?eissn), CONCAT("journal:", ?journalIdText)))) AS ?journalURI)
		}
}
