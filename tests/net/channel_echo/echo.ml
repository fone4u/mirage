(* Simple echo server that listens on 8081 and sends back everything it reads *)

open Lwt
open Printf
open Net

let echo () =
  lwt mgr,mgr_t = Manager.create () in
  (* Listen on all interfaces, port 8081 *)
  let src = (None, 8081) in 
  Channel.listen mgr (`TCPv4 (src,
    (fun (remote_addr, remote_port) t ->
       OS.Console.log (sprintf "Connection from %s:%d"
         (Nettypes.ipv4_addr_to_string remote_addr) remote_port);
       let rec echo () =
         try_lwt
           lwt res = Channel.read_crlf t in
           Channel.write_bitstring t res >>
           Channel.write_char t '\n' >>
           Channel.flush t >>
           echo ()
         with Nettypes.Closed -> return ()
       in
       echo () 
    )
  ))

let _ = OS.Main.run (echo ())
