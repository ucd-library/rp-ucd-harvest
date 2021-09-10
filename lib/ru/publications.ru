PREFIX bibo: <http://purl.org/ontology/bibo/>
PREFIX cite: <http://citationstyles.org/schema/>
PREFIX experts: <http://experts.ucdavis.edu/>
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


# Leave in previous insertionTimes, since it's a good indication we didn't clean
# our db.
#DELETE {
#  GRAPH experts: {
#    ?experts_work_id ucdrp:insertionDateTime ?t.
#  }
#} WHERE {
#  GRAPH harvest_oap: {
#    ?work oap:experts_work_id ?experts_work_id
#  }
#  GRAPH experts: {
#    ?experts_work_id ucdrp:insertionDateTime ?t.
#  }
#}

# First, Insert citation BIBO stuff
INSERT {
  GRAPH experts: {
    ?experts_work_id a ?bibo_type, ucdrp:work ;
    rdfs:label ?title ;
    bibo:status ?vivoStatus;
    ucdrp:best_source ?source;
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

  ?work
         oap:best_record/oap:source-name ?source;
         oap:best_native_record ?native;
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
  GRAPH experts: {
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
      ("public-url" bibo:uri)
      ("c-eschol-id" bibo:identifier)
      ("volume" bibo:volume)
      }

      ?native oap:field [ oap:name ?field_name ; oap:text ?field_text ].
  }};

# Insert any pagenumber
INSERT { GRAPH experts: {
  ?experts_work_id ucdrp:pagination_source ?page_source;
                   ucdrp:priority ?priority;
                   bibo:pageStart ?begin;
                   bibo:pageEnd ?end;
                   .
} }
WHERE {
  { select ?work (min(?mpriority) as ?mp) WHERE {
    VALUES (?msource ?mpriority) {
      ("verified-manual" 1) ("epmc" 2) ("pubmed" 3)  ("scopus" 4)("wos" 5) ("wos-lite" 6)
      ("crossref" 7)  ("dimensions" 8) ("arxiv" 9)("orcid" 10) ("dblp" 11)  ("cinii-english" 12)
      ("repec" 13)  ("figshare" 14)  ("cinii-japanese" 15) ("manual" 16)  ("dspace" 17) }
    GRAPH harvest_oap: {
      ?work oap:category "publication" ;
      oap:records/oap:record [ oap:source-name  ?msource;
                               oap:native/oap:field/oap:pagination [] ].
    }} group by ?work
  }
  {
    VALUES (?page_source ?priority) {
      ("verified-manual" 1) ("epmc" 2) ("pubmed" 3)  ("scopus" 4)("wos" 5) ("wos-lite" 6)
      ("crossref" 7)  ("dimensions" 8) ("arxiv" 9)("orcid" 10) ("dblp" 11)  ("cinii-english" 12)
      ("repec" 13)  ("figshare" 14)  ("cinii-japanese" 15) ("manual" 16)  ("dspace" 17) }

    GRAPH harvest_oap: {
      ?work oap:category "publication" ;
      oap:experts_work_id ?experts_work_id;
      oap:records/oap:record ?record .
      ?record oap:source-name  ?page_source;
              oap:native/oap:field/oap:pagination [oap:begin-page ?begin; oap:end-page ?end ].
    }
  }
  filter(?priority=?mp)
};


# Insert the Work Date in VIVO format.
INSERT {
  GRAPH experts: {
    ?experts_work_id vivo:dateTimeValue ?work_date.

    ?work_date a vivo:DateTimeValue ;
      vivo:dateTime ?workDateTime ;
      vivo:dateTimePrecision ?dateTimePrecision  .
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
    bind(uri(concat(str(?experts_work_id),"#date")) as ?work_date)
      BIND(xsd:dateTime(CONCAT(?workDateYear, "-", COALESCE(?workDateMonth, "01"), "-", COALESCE(?workDateDay, "01"), "T00:00:00")) AS ?workDateTime)
      BIND(COALESCE(?yearMonthDayPrecision, ?yearMonthPrecision, ?yearPrecision) AS ?dateTimePrecision)
}};


# If it appeared in a journal, identify that relationship
# the JournalURI calculation needs match the journal creation step
INSERT {
  GRAPH experts: {
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
