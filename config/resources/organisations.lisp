(define-resource administrative-unit ()
  :class (s-prefix "besluit:Bestuurseenheid")
  :properties `((:name :string ,(s-prefix "skos:prefLabel"))
                 (:classification :url ,(s-prefix "besluit:classificatie")))
  :has-many `((submission :via ,(s-prefix "omgeving:Rechtshandeling.verantwoordelijke")
                :as "submissions"
                :inverse t))
  :resource-base (s-url "http://data.lblod.info/id/bestuurseenheden/")
  :features '(include-uri)
  :on-path "administrative-units"
)

(define-resource organization ()
  :class (s-prefix "org:Organization")
  :properties `((:name :string ,(s-prefix "skos:prefLabel")))
  :has-many `((user :via ,(s-prefix "foaf:member")
                :as "members"))
  :resource-base (s-url "http://data.lblod.info/id/organisations/")
  :features '(include-uri)
  :on-path "organizations"
)
