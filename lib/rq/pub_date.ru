PREFIX oap: <http://oapolicy.universityofcalifornia.edu/vocab#>
PREFIX oapx: <http://experts.ucdavis.edu/oap/vocab#>
PREFIX vivo: <http://vivoweb.org/ontology/core#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX experts_oap: <http://experts.ucdavis.edu/oap/>
PREFIX experts_pubs: <http://experts.ucdavis.edu/pubs/>
PREFIX harvest_oap: <http://oapolicy.universityofcalifornia.edu/>

INSERT {
	GRAPH experts_oap: {
		?publication vivo:dateTimeValue [ a vivo:DateTimeValue ; vivo:dateTime ?publicationDateTime ;  vivo:dateTimePrecision ?dateTimePrecision ]  .
		?dateTimePrecision a vivo:DateTimePrecision .
	}
}
WHERE {
	GRAPH harvest_oap: {
		?publication oap:records/oap:record ?exemplarRecord .

		{
			?exemplarRecord oap:native/oap:field [ oap:name "publication-date" ; oap:date ?publicationDate ].
		}
		UNION
		{
			?exemplarRecord oap:native/oap:field [ oap:name "online-publication-date" ; oap:date ?publicationDate ].
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
