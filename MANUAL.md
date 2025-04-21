# Uruchamianie

`dune exec ./bin/main.exe <nazwa_pliku>`
`<nazwa_pliku>` jest dowolna.

# Komunikacja z serwerem

Odbywa się zwykłym GET-em na odpowiedni port (8080), zapytanie powinno być w parametrze `query` (zakodowane "procentowo").

# Operacje

Program obsługuje:

- proste operacje wstawienia

```
INSERT DATA {bob hasHeight 180 . bob knows alice . alice hasHeight 170 . bob hasName "Bob" .}
```

- proste zapytania

```
SELECT ?x WHERE {?x hasHeight 180 .}
```

```
SELECT ?x WHERE {?x knows ?y . ?y hasHeight 170 .}
```

Prostym spodobem komunikacji z serwerem jest użycie curl-a:
`curl --get --data-urlencode "query=SELECT ?x ?y ?z WHERE {?x ?y ?z .}" "localhost:8080/"`.

# Testy

Podstawowe testy znajdują się w katalogu `test`, można je uruchomić za pomocą `dune runtest`. Są to testy, które wysyłają zapytania do serwera i sprawdzają odpowiedzi. Mogą to też być przykłady zapytań pokazujące co da się zrobić.
