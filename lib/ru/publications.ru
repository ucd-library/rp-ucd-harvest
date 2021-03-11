PREFIX bibo: <http://purl.org/ontology/bibo/>
PREFIX cite: <http://citationstyles.org/schema/>
PREFIX experts: <http://experts.ucdavis.edu/>
PREFIX experts_oap: <http://experts.ucdavis.edu/oap/>
PREFIX experts_pub: <http://experts.ucdavis.edu/pub/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX harvest_oap: <http://oapolicy.universityofcalifornia.edu/>
PREFIX list: <http://jena.apache.org/ARQ/list#>
PREFIX oap: <http://oapolicy.universityofcalifornia.edu/vocab#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX ucdrp: <http://experts.ucdavis.edu/schema#>
PREFIX vcard: <http://www.w3.org/2006/vcard/ns#>
PREFIX vivo: <http://vivoweb.org/ontology/core#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX venue: <http://experts.ucdavis.edu/venue/>
PREFIX work: <http://experts.ucdavis.edu/work/>
PREFIX authorship: <http://experts.ucdavis.edu/authorship/>

# First, Insert citation BIBO stuff
INSERT {
  GRAPH experts_oap: {
    ?experts_work_id a ?bibo_type, ucdrp:work ;
    rdfs:label ?title ;
    bibo:pageStart ?beginPage ;
    bibo:pageEnd ?endPage ;
    bibo:status ?vivoStatus;
		ucdrp:lastModifiedDateTime ?lastModifiedDateTime ;
		ucdrp:insertionDateTime ?insertionDateTime;
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

  ?work oap:best_native_record ?native;
			   oap:type ?oap_type ;
         oap:experts_work_id ?experts_work_id;
         oap:work_number ?pub_id;
			   oap:last-modified-when ?lastModifiedWhen .
  BIND(xsd:dateTime(?lastModifiedWhen) AS ?lastModifiedDateTime)
  BIND(NOW() as ?insertionDateTime)

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
    ?experts_work_id ?bibo_predicate ?field_text.
  }
}
WHERE {
  GRAPH harvest_oap: {
    ?work oap:best_native_record ?native;
               oap:experts_work_id ?experts_work_id;
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

# Insert the Work Date in VIVO format.
INSERT {
  GRAPH experts_oap: {
    ?experts_work_id vivo:dateTimeValue [ a vivo:DateTimeValue ; vivo:dateTime ?workDateTime ;  vivo:dateTimePrecision ?dateTimePrecision ]  .
    ?dateTimePrecision a vivo:DateTimePrecision .
  }
}
WHERE {
  GRAPH harvest_oap: {
    ?work oap:best_native_record ?native;
               oap:experts_work_id ?experts_work_id;
    .

    {
    ?native oap:field [ oap:name "publication-date" ; oap:date ?workDate ].
    }
    UNION
    {
      ?native oap:field [ oap:name "online-publication-date" ; oap:date ?workDate ].
    }
    ?workDate oap:year ?workDateYear
    BIND(vivo:yearPrecision AS ?yearPrecision)
    OPTIONAL {
      ?workDate oap:month ?workDateMonthRaw
      BIND(IF(xsd:integer(?workDateMonthRaw) < 10, CONCAT("0", ?workDateMonthRaw), ?workDateMonthRaw) AS ?workDateMonth)
      BIND(vivo:yearMonthPrecision AS ?yearMonthPrecision)
      OPTIONAL {
        ?workDate oap:day ?workDateDayRaw
        BIND(IF(xsd:integer(?workDateDayRaw) < 10, CONCAT("0", ?workDateDayRaw), ?workDateDayRaw) AS ?workDateDay)
        BIND(vivo:yearMonthDayPrecision AS ?yearMonthDayPrecision)
      }
    }
      BIND(xsd:dateTime(CONCAT(?workDateYear, "-", COALESCE(?workDateMonth, "01"), "-", COALESCE(?workDateDay, "01"), "T00:00:00")) AS ?workDateTime)
      BIND(COALESCE(?yearMonthDayPrecision, ?yearMonthPrecision, ?yearPrecision) AS ?dateTimePrecision)
}};

# Next Insert Authors.  Do this seperately, so we don't needlessly check
# work level values

INSERT {
  GRAPH experts_oap: {
    ?authorship a vivo:Authorship,ucdrp:authorship ;
    vivo:rank ?authorRank ;
    vivo:relates ?personURI ;
    vivo:relates ?experts_work_id ;
    vivo:favorite ?favorite;
    ?vivorelates [ a ?vcardIndividual ;
                   vivo:relatedBy ?vcard ;
                   ?vcardhasName [ a ?vcardName ;
                                   vcard:familyName ?authorLastName ;
                                   vcard:givenName ?authorFirstName ;
                                 ] ;
                 ] .
		?experts_work_id vivo:relatedBy ?authorship.
		?personURI vivo:relatedBy ?authorship.
  }
}
WHERE { GRAPH harvest_oap: {
  ?work oap:best_native_record ?native;
              oap:experts_work_id ?experts_work_id;
             oap:work_number ?pub_id;
  .

  ?native oap:field [ oap:name "authors" ; oap:people/oap:person [ list:index(?pos ?elem) ] ] .
  BIND(?pos+1 AS ?authorRank)
	BIND(uri(concat(replace(str(?experts_work_id),str(work:),str(authorship:)),"-",str(?authorRank))) as ?authorship)

	# Everything of the blank node needs to be a variable, or else we'll happily create
	# empty nodes
	OPTIONAL {
    bind(vcard:Name as ?vcardName)
    bind(vcard:Individual as ?vcardIndividual)
    bind(vivo:relates as ?vivorelates)
    bind(vcard:hasName as ?vcardhasName)
		?elem oap:last-name ?authorLastName ;
  		  oap:first-names ?authorFirstName ;
		.
		?elem oap:last-name ?authorLastName ;
		oap:first-names ?authorFirstName ;
		.
		NOT EXISTS {
			graph experts_oap: {
				?authorship vivo:relates [ a vcard:Individual; vcard:hasName [ a vcard:Name ]] .
			}
		}
	}

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
    BIND(URI(CONCAT(STR("http://experts.ucdavis.edu/person/"),md5(STRBEFORE(?username,"@")))) AS ?personURI)
  }
}};

# If it appeared in a journal, identify that relationship
# the JournalURI calculation needs match the journal creation step
INSERT {
  GRAPH experts_oap: {
    ?experts_work_id vivo:hasPublicationVenue ?journalURI .
    ?journalURI vivo:publicationVenueFor ?experts_work_id .
  }
}
WHERE {
  GRAPH harvest_oap: {
    ?work oap:best_native_record ?native;
               oap:experts_work_id ?experts_work_id;
    .

    ?native oap:field [ oap:name "journal" ; oap:text ?journalTitle ].
    BIND(REPLACE(REPLACE(LCASE(STR(?journalTitle)), '[^\\w\\d]','-'), '-{2,}' ,'-') AS ?journalIdText)
    OPTIONAL {
      ?native oap:field [ oap:name "eissn" ; oap:text ?eissn ].
    }
    OPTIONAL {
      ?native oap:field [ oap:name "issn" ; oap:text ?issn ].
    }
    BIND(URI(CONCAT(str(venue:), COALESCE(CONCAT("issn:", ?issn), CONCAT("eissn:", ?eissn), CONCAT("journal:", ?journalIdText)))) AS ?journalURI)
    }
}
