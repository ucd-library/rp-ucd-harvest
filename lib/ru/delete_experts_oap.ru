# For our purposes then, in the
#  name_www_flag/name_ucd_flags are unchecked then we will assume the user wants
#  then entire ODR section not included, and since they don't show up in the
#  directory search, I think we'll take that to mean to not to include any PPS
#  data as well.

PREFIX experts: <http://experts.ucdavis.edu/>
DELETE {} WHERE {
  graph ?experts: { ?s ?p ?o . }
}
