# Somewhat abstract file structure

## Indexes

The file, except for metadata and index of indexes, comprises only of indexes.

## Index of indexes

A special page, always at the top, containing information about the root pages of all indexes. It is just one page and the data on it is a simple list.

## Indirection

Each actual datum is represented by a unique (across **all data**) ID.
Therefore, the file has two types of pages^[except for metadata in the header and index of indexes]:

- translation pages, storing indexes to transform an ID into datum and vice versa
- data pages, storing indexes for triples.

## Data types

The data types are: IRIs, blank nodes and all types of literals. Note that IRIs, even though represented using strings are treated as separate from string literals.
For every data type there are two indexes: one for translating IDs into datum and one the other way around.
Each data type has a one-byte unique identifier.

## ID

Each ID is an unsigned int64. First byte contains the identifier of the referenced datum type.
