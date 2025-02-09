let () =
  Logging.init false;
  Network.Server.run 8080
