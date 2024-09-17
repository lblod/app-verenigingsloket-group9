;;;;;;;;;;;;;;;;;;;
;;; delta messenger
(in-package :delta-messenger)

;; (push (make-instance 'delta-logging-handler) *delta-handlers*) ;; enable if delta messages should be logged on terminal
(add-delta-messenger "http://delta-notifier/")
(setf *log-delta-messenger-message-bus-processing* nil) ;; set to t for extra messages for debugging delta messenger

;;;;;;;;;;;;;;;;;
;;; configuration
(in-package :client)
(setf *log-sparql-query-roundtrip* nil) ; change nil to t for logging requests to virtuoso (and the response)
(setf *backend* "http://triplestore:8890/sparql")

(in-package :server)
(setf *log-incoming-requests-p* nil) ; change nil to t for logging all incoming requests

;;;;;;;;;;;;;;;;
;;; prefix types
(in-package :type-cache)

(add-type-for-prefix "http://mu.semte.ch/sessions/" "http://mu.semte.ch/vocabularies/session/Session") ; each session URI will be handled for updates as if it had this mussession:Session type

;;;;;;;;;;;;;;;;;
;;; access rights

(in-package :acl)

;; these three reset the configuration, they are likely not necessary
(defparameter *access-specifications* nil)
(defparameter *graphs* nil)
(defparameter *rights* nil)

;; Prefixes used in the constraints below (not in the SPARQL queries)
(define-prefixes
  ;; Core
  :mu "http://mu.semte.ch/vocabularies/core/"
  :session "http://mu.semte.ch/vocabularies/session/"
  :ext "http://mu.semte.ch/vocabularies/ext/"
  ;; Custom prefix URIs here, prefix casing is ignored
  :foaf "http://xmlns.com/foaf/0.1/"
  :dct "http://purl.org/dc/terms/"
  :besluit "http://data.vlaanderen.be/ns/besluit#"
  :org "http://www.w3.org/ns/org#Organization"
  :omgeving "https://data.vlaanderen.be/ns/omgevingsvergunning#"
  :adms "http://www.w3.org/ns/adms#"
  :time "http://www.w3.org/2006/time#"
  :geosparql "http://www.opengis.net/ont/geosparql#"
  :dbpedia "http://dbpedia.org/resource/"
  )

;;;;;;;;;
;; Graphs
;;
;; These are the graph specifications known in the system.  No
;; guarantees are given as to what content is readable from a graph.  If
;; two graphs are nearly identitacl and have the same name, perhaps the
;; specifications can be folded too.  This could help when building
;; indexes.

(define-graph public ("http://mu.semte.ch/graphs/public")
  ("skos:ConceptScheme" -> _)
  ("skos:Concept" -> _)
  ("besluit:Bestuurseenheid" -> _)
  ("org:Organization" -> _))

(define-graph users ("http://mu.semte.ch/graphs/users")
  ("foaf:Person"
    -> "foaf:name"
    -> "foaf:account"
    -> "dct:created"
    -> "dct:modified")
  ("foaf:OnlineAccount"
    -> "foaf:accountName"
    -> "foaf:accountServiceHomepage"
    -> "dct:created"
    -> "dct:modified"))

(define-graph organization ("http://mu.semte.ch/graphs/organizations/")
  ("dbpedia:Case" -> _)
  ("omgeving:Activiteit" -> _)
  ("omgeving:Aanvraag" -> _)
  ("adms:Identifier" -> _)
  ("geosparql:Feature" -> _)
  ("time:Interval" -> _)
  ("omgeving:Vergunning" -> _)
  ("besluit:Besluit" -> _))

;; Example:
;; (define-graph company ("http://mu.semte.ch/graphs/companies/")
;;   ("foaf:OnlineAccount"
;;    -> "foaf:accountName"
;;    -> "foaf:accountServiceHomepage")
;;   ("foaf:Group"
;;    -> "foaf:name"
;;    -> "foaf:member"))


;;;;;;;;;;;;;
;; User roles

(supply-allowed-group "public")

(supply-allowed-group "logged-in"
  :parameters ()
  :query "PREFIX session: <http://mu.semte.ch/vocabularies/session/>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX mu: <http://mu.semte.ch/vocabularies/core/>
      SELECT ?account WHERE {
          <SESSION_ID> session:account ?account .
      } LIMIT 1")

(supply-allowed-group "organization-member"
  :parameters ("organization_uuid")
  :query "PREFIX session: <http://mu.semte.ch/vocabularies/session/>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX mu: <http://mu.semte.ch/vocabularies/core/>
      SELECT ?organizationUuid ?account WHERE {
          <SESSION_ID> session:account ?account .
          ?user foaf:account ?account .
          ?organization foaf:member ?user ;
            mu:uuid ?organization_uuid .
      } LIMIT 1")

(grant (read)
       :to-graph public
       :for-allowed-group "public")

(grant (read)
       :to-graph users
       :for-allowed-group "logged-in")

(grant (write)
       :to-graph organization
       :for-allowed-group "organization-member")

;; example:

;; (supply-allowed-group "company"
;;   :query "PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
;;           SELECT DISTINCT ?uuid WHERE {
;;             <SESSION_ID ext:belongsToCompany/mu:uuid ?uuid
;;           }"
;;   :parameters ("uuid"))

;; (grant (read write)
;;        :to company
;;        :for "company")
