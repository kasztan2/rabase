let init debug =
  let reporter = Logs_fmt.reporter () in
  Logs.set_reporter reporter;
  Logs.set_level
    (Some (match debug with true -> Logs.Debug | false -> Logs.Info))
