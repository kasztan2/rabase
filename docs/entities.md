# Entities

## Numbers

> Not to be confused with a literal type, this specifies the general number type of data in the file

Numbers are generally unsigned, except where noted otherwise. They should be interpreted as having the maximum range possible based on storage space, for example if a number is 2-byte then it should be assumed that its range is from 0 to $2^{16}-1$.

## IDs

IDs are for referencing item and literal data. They occupy allways 8 bytes, and the first one specifies the type of referenced data as in _datatypes.md_.

## Page Numbers (addresses)

Page number is always a 4-byte integer.
