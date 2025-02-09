include Opium
open Lwt.Syntax

(* adapted from https://github.com/rgrinberg/opium/blob/73b16f0487497e02750c1123ead377a56be3be43/opium/src/app.ml#L361 *)
module App = struct
  include Opium.App

  let run_command' app =
    Lwt.async (fun () ->
        let* _server = Opium.App.start app in
        Lwt.return_unit);
    let forever, _ = Lwt.wait () in
    `Ok forever
end
