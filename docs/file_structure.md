# General structure

The file is comprised of 4096 bytes long pages.
The first page is always a _header page_, the order of other pages is free and does not need to follow any rules.
**Numbers are to be interpreted as unsigned except where noted otherwise.**

## Types of pages

### Header page

Special page that is always the first page in the file and contains metadata about the file (database) and about the file structure (_pointers_).

### Data pages

Data pages contain indexes for triples (and the actual triples).

### Translation pages

Translation pages contain information required to translate an ID into a value and vice versa.
Therefore, there are two types of translation pages, one for each direction of translation.

## Header page

The header page consists of a small header and a list of root pages for indexes.

### Header structure

| Number of bytes | Description                                    | Total bytes from start |
| --------------- | ---------------------------------------------- | ---------------------- |
| 6               | encoded text "rabase"                          | 6                      |
| 10              | **not used**                                   | 16                     |
| 4               | Number of pages in total (including free ones) | 20                     |
| 4               | Number of free pages                           | 24                     |
| 8               | Autoincremented ID for new data references     | 32                     |
| 32              | Reserved for extensions                        | 64                     |

### List of indexes

Each of the page numbers is stored as a 4 byte integer^[unsigned, obviously]. The list does not contain any other information than the page numbers, the order dictates what the numbers stand for.
The order is:

| Order     | Root page number of           |
| --------- | ----------------------------- |
| 0         | SPO                           |
| 1         | SOP                           |
| 2         | PSO                           |
| 3         | POS                           |
| 4         | OSP                           |
| 5         | OPS                           |
| 6-261     | ID -> value, for each type    |
| 262 - 517 | value -> index, for each type |

Data types are ordered by their IDs (specified in _datatypes_).

## General page structure (small header)

Each page of data or translation type has the first two bytes specify the order, as per the above table.
Next they contain a byte of value 0 for an interior page and 1 for a leaf page.
This will be omitted from the detailed descriptions below, but comes before all type-specific structure elements.

## Data pages

Data pages contain parts of a B+-tree ordered by the appropriate _three-letter ordering_.

> This is a rather weird B+-tree as the data in interior nodes is actually just duplicated in leaves. For simplicity, all three fields of a triple are stored, as they could be needed for a comparison. The advantage of a B+-tree over a B-tree is the _linked list_ comprised of leaves containing all the data in sorted order.

There are therefore leaf and interior data pages.
Triples are in the form of references, i.e.: `subject ID, predicate ID, object ID`. They occupy always exactly 24 bytes, as all IDs each occupy 8 bytes.

### Structure

> The triples' fields are arranged in the order corresponging to the index type. For example if the index type is PSO, the triples will be arranged in the form of `predicate ID, subject ID, object ID`.
> The triples are ordered using the index order.

#### Interior Page Structure

| Section              | Size (Bytes)      | Description                                                             |
| -------------------- | ----------------- | ----------------------------------------------------------------------- |
| **Header**           | **7 bytes**       |                                                                         |
| - Order              | 2 bytes           | Specifies the order of this page (index type).                          |
| - Page type          | 1 byte            | Always `0` for interior pages.                                          |
| - Sibling            | 4 bytes           | Ignored for interior pages.                                             |
| **Content**          | **Rest**          |                                                                         |
| - Triple Count       | 1 byte            | Number of triples stored ($N$).                                         |
| - Child Page Numbers | $(N+1) * 4$ bytes | List of child page numbers.                                             |
| - Free Space         | Variable          | Used to align triples at the end of the page.                           |
| - Triples            | $N * 24$ bytes    | Ordered triples with fields: `[Field1][Field2][Field3]` (8 bytes each). |

#### Leaf Page Structure

| Section        | Size (Bytes)   | Description                                                             |
| -------------- | -------------- | ----------------------------------------------------------------------- |
| **Header**     | **7 bytes**    |                                                                         |
| - Order        | 2 bytes        | Specifies the order of this page (index type).                          |
| - Page type    | 1 byte         | Always `1` for leaf pages.                                              |
| - Sibling      | 4 bytes        | Page number of the next sibling.                                        |
| **Content**    | **Rest**       |                                                                         |
| - Triple Count | 1 byte         | Number of triples stored ($N$).                                         |
| - Free Space   | Variable       | Used to align triples at the end of the page.                           |
| - Triples      | $N * 24$ bytes | Ordered triples with fields: `[Field1][Field2][Field3]` (8 bytes each). |

---

For example for PSO index: Field1=Predicate, Field2=Subject, Field3=Object.

Maximum number of stored triples (_N_) is 128, for both the interior and leaf pages.

## Translation pages

Translation pages represent parts of a B+-tree, that is used to translate ID to value or value to ID^[note that an identifier is not an ID in this context].

Here, contrary to data pages, all data is not duplicated, as the key does not contain both ID and value.

Pages are split only if data about to be inserted cannot fit (there is _de facto_^[the number of items/keys is stored in 2-byte integer, but the limit will in fact be around 4000, because there is no way to point to bits, therefore no such data type] limit on keys/items per page).

### Structure for fixed-size keys

#### Interior Page Structure

| Section              | Size (Bytes)         | Description                                    |
| -------------------- | -------------------- | ---------------------------------------------- |
| **Header**           | **7 bytes**          |                                                |
| - Order              | 2 bytes              | Specifies the order of this page (index type). |
| - Page type          | 1 byte               | Always `0` for interior pages.                 |
| - Sibling            | 4 bytes              | Ignored for interior pages.                    |
| **Content**          | **Rest**             |                                                |
| - Keys Count         | 2 bytes              | Number of keys stored ($N$).                   |
| - Child Page Numbers | $(N+1) * 4$ bytes    | List of child page numbers.                    |
| - Free Space         | Variable             | Used to align keys at the end of the page.     |
| - Keys               | Depends on data type | Keys in order.                                 |

#### Leaf Page Structure

| Section                   | Size (Bytes)         | Description                                    |
| ------------------------- | -------------------- | ---------------------------------------------- |
| **Header**                | **7 bytes**          |                                                |
| - Order                   | 2 bytes              | Specifies the order of this page (index type). |
| - Page type               | 1 byte               | Always `1` for leaf pages.                     |
| - Sibling                 | 4 bytes              | Page number of the next sibling.               |
| **Content**               | **Rest**             |                                                |
| - Item Count              | 2 bytes              | Number of items stored ($N$).                  |
| - Free Space              | Variable             | Used to align items at the end of the page.    |
| - List of keys and values | Depends on data type | Items (key + value) ordered by key             |

### Structure for variable-size keys

#### Interior Page Structure

| Section                                 | Size (Bytes)            | Description                                    |
| --------------------------------------- | ----------------------- | ---------------------------------------------- |
| **Header**                              | **7 bytes**             |                                                |
| - Order                                 | 2 bytes                 | Specifies the order of this page (index type). |
| - Page type                             | 1 byte                  | Always `0` for interior pages.                 |
| - Sibling                               | 4 bytes                 | Ignored for interior pages.                    |
| **Content**                             | **Rest**                |                                                |
| - Keys Count                            | 2 bytes                 | Number of keys stored ($N$).                   |
| - Child Page Numbers & Pointers to Keys | $(N+1) * 4 + N*2$ bytes | List: `(PageNumber, Pointer)*N, PageNumber`.   |
| - Free Space                            | Variable                | Used to align keys at the end of the page.     |
| - Keys                                  | Depends on data         | Keys in order.                                 |

#### Leaf Page Structure

| Section                           | Size (Bytes)         | Description                                    |
| --------------------------------- | -------------------- | ---------------------------------------------- |
| **Header**                        | **7 bytes**          |                                                |
| - Order                           | 2 bytes              | Specifies the order of this page (index type). |
| - Page type                       | 1 byte               | Always `1` for leaf pages.                     |
| - Sibling                         | 4 bytes              | Page number of the next sibling.               |
| **Content**                       | **Rest**             |                                                |
| - Item Count                      | 2 bytes              | Number of items stored ($N$).                  |
| - Pointer to Items                | $N * 4$ bytes        | Pointers to items.                             |
| - Free Space                      | Variable             | Used to align items at the end of the page.    |
| - List of keys and values (items) | Depends on data type | Items (key + value) ordered by key             |
