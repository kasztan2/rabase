(lang dune 3.16)

(name rabase)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Krzysztof Chorzempa")

(maintainers "Krzysztof Chorzempa")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name rabase)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends
  (ocaml
   (>= 5.3))
  dune
  stdint
  (core
   (= v0.15.0))
  (opium
   (>= 0.20.0))
  (ppx_deriving
   (>= 6.0.3))
  (ppx_import
   (>= 1.11.0)))
 (tags
  (topics "to describe" your project)))

(using menhir 3.0)

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
