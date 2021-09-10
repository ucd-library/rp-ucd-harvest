# For our purposes then, in the
#  name_www_flag/name_ucd_flags are unchecked then we will assume the user wants
#  then entire ODR section not included, and since they don't show up in the
#  directory search, I think we'll take that to mean to not to include any PPS
#  data as well.

PREFIX experts: <http://experts.ucdavis.edu/>
PREFIX person: <http://experts.ucdavis.edu/person/>
PREFIX experts: <http://experts.ucdavis.edu/>
PREFIX harvest_iam: <http://iam.ucdavis.edu/>
PREFIX iam: <http://iam.ucdavis.edu/schema#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ucdrp: <http://experts.ucdavis.edu/schema#>
PREFIX vcard: <http://www.w3.org/2006/vcard/ns#>
PREFIX vivo: <http://vivoweb.org/ontology/core#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

#First Delete all existing records, (Should this be in oap as well?)
#DELETE { graph experts: {?user ?p ?o }}
#WHERE {
#  graph experts: {?user ?p ?o .}
#  graph harvest_iam: {
#    ?s iam:email ?email;
#       iam:userID ?kerb;
#       iam:dLastName ?iam_lname;
#       iam:dFirstName ?iam_fname;
#       iam:isFaculty ?faculty
#    .
#    bind(uri(concat(str(experts:),md5(?kerb))) as ?user)
#  }
#};

INSERT {
	graph experts: {
  ?user a ?emp_type, ucdrp:person;
          rdfs:label ?label;
          ucdrp:casId ?kerb;
          ucdrp:indentifier ?user_id;
          obo:ARG_2000028 _:vcard;
  .
  _:vcard a vcard:Individual;
            ucdrp:identifier ?vid;
            vivo:rank ?order ;
            vcard:hasName [a vcard:Name;
                vcard:givenName ?fname;
                vcard:familyName ?lname;
                ];
            vcard:hasTitle [
                a vcard:Title;
                vcard:title ?title];
            vcard:hasOrganizationalUnit [
                a vcard:Organization;
                vcard:title ?dept
                ];
            vcard:hasEmail [a vcard:Email,vcard:Work;
                vcard:email ?email];
   .
} } WHERE {
  select ?user ?label ?kerb ?vid ?title ?email ?dept ?fname ?lname ?order ?emp_type
  where { graph harvest_iam: {
    ?s iam:email ?email;
       iam:userID ?kerb;
       iam:dLastName ?iam_lname;
       iam:dFirstName ?iam_fname;
       iam:isFaculty ?faculty
    .
    OPTIONAL {
      {
        select ?s ?vid ?better_fname ?better_lname ?title ?dept ?order
        WHERE { graph harvest_iam: {
           ?s iam:directory ?dir .
          ?dir iam:listings ?list;
               iam:displayName [ iam:nameWwwFlag "Y";
                                iam:preferredFname ?better_fname;
                                iam:preferredLname ?better_lname ];
                                                   .
          OPTIONAL {
            ?list iam:deptWwwFlag "Y";
                  iam:listingOrder ?order;
                  iam:title ?title;
                  iam:deptName ?dept;
                  .
            bind(concat("odr-",str(?order)) as ?vid)
          }
        }}
      } UNION {
        select ?s ?vid ?better_fname ?better_lname ?title ?dept ?order
        where { graph harvest_iam: {
          ?s iam:ppsAssociations [iam:assocRank ?a_order;
                                 iam:titleOfficialName ?otitle;
                                 iam:deptOfficialName ?dept ];
                                                      .
          bind(replace(?otitle," -.*","") as ?title)
          bind(xsd:integer(?a_order)+10 as ?order)
          bind(concat("pps-",str(?a_order)) as ?vid)
        } }
      }
    }
    bind(coalesce(?better_fname,?iam_fname) as ?fname)
    bind(coalesce(?better_lname,?iam_lname) as ?lname)
    bind(concat(?fname," ",?lname) as ?label)

    bind(md5(?kerb) as ?user_id)
    bind(uri(concat(str(person:),?user_id)) as ?user)
    bind(if(?faculty=true,vivo:FacultyMember,vivo:NonAcademic) as ?emp_type)
  }}
}
