let header_template =
  let buf = Buffer.create 4096 in
  Buffer.add_string buf "rabase";
  Buffer.add_bytes buf (Bytes.make 10 '\000');
  Buffer.add_bytes buf (Bytes.make 4080 '\000');
  Buffer.to_bytes buf
