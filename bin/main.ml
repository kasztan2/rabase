let () =
  Logging.init ();
  Network.Server.run 8080
