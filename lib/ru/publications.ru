PREFIX bibo: <http://purl.org/ontology/bibo/>
PREFIX cite: <http://citationstyles.org/v1.0/schema#>
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


  # Remove insertionDate for now
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
    cite:title ?title ;
    cite:type ?cite_type;
    cite:genre ?cite_genre;
    cite:status ?status;
    bibo:status ?vivoStatus;
    ucdrp:best_source ?source;
		ucdrp:lastModifiedDateTime ?lastModifiedDateTime ;
#		ucdrp:insertionDateTime ?insertionDateTime;
    .
  }
}
WHERE { GRAPH harvest_oap: {
  VALUES(?oap_type ?bibo_type ?cite_type){
    ("book" bibo:Book "book" "")
    ("chapter" bibo:Chapter "chapter" "")
    ("conference" vivo:ConferencePaper "paper-conference" "")
    ("dataset" ucdrp:work "dataset" "")
    ("internet-publication" ucdrp:work "webpage" "")
    ("journal-article" bibo:AcademicArticle "article-journal" "")
    ("media" ucdrp:work "article" "media")
    ("other" ucdrp:work "article" "other")
    ("poster" ucdrp:work "speech" "poster")
    ("preprint" ucdrp:PrePrint "article" "preprint" )
    ("presentation" ucdrp:work "speech" "presentation")
    ("report" ucdrp:work "report" "")
    ("scholarly-edition" ucdrp:work "manuscript" "scholarly-edition")
    ("software" ucdrp:work "software")
    ("thesis-dissertation" ucdrp:work "thesis" "disseration")
  }

    VALUES(?oap_type ?cite_genre){
    ("media" "media")
    ("other" "other")
    ("poster" "poster")
    ("preprint" "preprint" )
    ("presentation" "presentation")
    ("scholarly-edition" "scholarly-edition")
    ("thesis-dissertation" "disseration")
  }


  ?work
         oap:best_record/oap:source-name ?source;
         oap:best_native_record ?native;
			   oap:type ?oap_type ;
         oap:experts_work_id ?experts_work_id;
         oap:work_number ?pub_id;
			   oap:last-modified-when ?lastModifiedWhen .
  BIND(xsd:dateTime(?lastModifiedWhen) AS ?lastModifiedDateTime)
#  BIND(NOW() as ?insertionDateTime)

  ?native oap:field [ oap:name "title" ; oap:text ?title ] .

  OPTIONAL {
    ?native oap:field [ oap:name "pagination" ; oap:pagination [ oap:begin-page ?beginPage ; oap:end-page ?endPage ] ].
  }

  OPTIONAL {
    VALUES (?status ?vivoStatus) { ( "Published" bibo:published ) ( "Published online" bibo:published ) ( "Accepted" bibo:accepted ) }
    ?exemplarRecord oap:native/oap:field [ oap:name "publication-status" ; oap:text ?status ]
  }

}};

# Now insert optional bibo/cite entries
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

    VALUES(?field_name ?predicate) {
#      ("abstract" bibo:abstract)
#      ("author-url" bibo:uri)
      ("doi" bibo:doi)
#      ("isbn-10" bibo:isbn10)
#      ("isbn-13" bibo:isbn13)
#      ("issue" bibo:issue)
#      ("journal" bibo:journal)
#      ("number" bibo:number)
#      ("publish-url" bibo:uri)
#      ("public-url" bibo:uri)
#      ("c-eschol-id" bibo:identifier)
#      ("volume" bibo:volume)
      ("abstract" cite:abstract)
      ("acceptance-date" cite:issued)
      #("addresses" cite:)
      #("altmetric-attention-score" cite:)
      #("associated-identifiers" cite:)
      #("author-url" cite:)
      #("authors" cite:)
      #("c-eschol-id" cite:)
      #("c-uci-id" cite:)
      #("c-ucsf-id" cite:)
      #("collections" cite:)
      #("confidential" cite:)
      ("doi" cite:DOI)
      ("edition" cite:edition)
      #("editors" cite:)
      ("eissn" cite:eissn)
      #("embargo-release-date" cite:)
      ("external-identifiers" cite:)
      #("field-citation-ratio" cite:)
      #("filed-date" cite:)
      #("finish-date" cite:)
      ("is-open-access" ucdrp:is-open-access)
      ("isbn-10" cite:ISBN)
      ("isbn-13" cite:ISBN)
      ("issn" cite:ISSN)
      ("issue" cite:issue)
      ("journal" cite:container-title)
      ("keywords" cite:keyword)
      ("language" cite:language)
      #("location" cite:)
      ("medium" cite:medium)
      ("name-of-conference" cite:container-title)
      ("notes" cite:note)
      ("number" cite:collection-number)
      ("oa-location-url" cite:url)
      ("online-publication-date" cite:avaliable-date)
      ("pagination" cite:pagination)
      ("parent-title" cite:container-title)
      #("pii" cite:)
      ("place-of-publication" cite:publisher-place)
      ("public-url" cite:url)
      ("publication-date" cite:issued)
      ("publication-status" cite:status)
      ("publisher" cite:publisher)
      ("publisher-licence" cite:license)
      #("publisher-url" cite:)
      #("record-created-at-source-date" cite:)
      #("record-made-public-at-source-date" cite:)
      #("relative-citation-ratio" cite:)
      #("repository-status" cite:)
      ("series" cite:collection-number)
      #("start-date" cite:)
      ("thesis-type" cite:genre) # Hopefully cite:type set correctly
      ("title" cite:title)
      #("types" cite:genre) Handled elsewhere
      ("volume" cite:volume)
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


# Insert the Work Date in VIVO format and in cite:format
INSERT {
  GRAPH experts: {
    ?experts_work_id vivo:dateTimeValue ?work_date;
                     ?date_pred ?work_date;
                     .

    ?work_date a vivo:DateTimeValue ;
      cite:date ?cite_date;
      vivo:dateTime ?workDateTime ;
      vivo:dateTimePrecision ?dateTimePrecision  .
  }
}
WHERE {
  GRAPH harvest_oap: {

    values(?date_name ?date_pred) {
      ("publication-date" cite:issued)
      ("online-publication-date" cite:available-date)
    }

    [] oap:best_native_record/oap:field [ oap:name ?date_name ;
                                          oap:date ?workDate ];
          oap:experts_work_id ?experts_work_id;
    .


    ?workDate oap:year ?workDateYear
    BIND(vivo:yearPrecision AS ?delta_y)
    BIND(?workDateYear as ?cite_y)
    OPTIONAL {
      ?workDate oap:month ?workDateMonthRaw
      BIND(IF(xsd:integer(?workDateMonthRaw) < 10, CONCAT("0", ?workDateMonthRaw), ?workDateMonthRaw) AS ?workDateMonth)
      BIND(concat(?workDateYear,"-",?workDateMonth) as ?cite_ym)
      BIND(vivo:yearMonthPrecision AS ?delta_ym)
      OPTIONAL {
        ?workDate oap:day ?workDateDayRaw
        BIND(IF(xsd:integer(?workDateDayRaw) < 10, CONCAT("0", ?workDateDayRaw), ?workDateDayRaw) AS ?workDateDay)
        BIND(concat(?workDateYear,"-",?workDateMonth,"-",?workDateDay) as ?cite_ymd)
        BIND(vivo:yearMonthDayPrecision AS ?delta_ymd)
      }
    }
      BIND(xsd:dateTime(CONCAT(?workDateYear, "-", COALESCE(?workDateMonth, "01"), "-", COALESCE(?workDateDay, "01"), "T00:00:00")) AS ?workDateTime)
    BIND(COALESCE(?delta_ymd,?delta_ym,?delta_y) AS ?dateTimePrecision)
    BIND(COALESCE(?cite_ymd, ?cite_ym, ?cite_y) AS ?cite_date)
    bind(uri(concat(str(?experts_work_id),'#',?cite_date)) as ?work_date)

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
