(*
 * Copyright (c) 2011 Anil Madhavapeddy <anil@recoil.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

(* The manager binds the external functions we need from the platform.
   Some duplication with the Net manager *)

open Lwt
open Printf

exception Error of string

module Unix = struct
  type 'a fd

  type 'a resp =
  | OK of 'a
  | Err of string
  | Retry

  external file_open_readonly: string -> [`ro_file] fd resp = "caml_file_open_readonly"

  external read: [`ro_file] fd -> string -> int -> int -> int resp = "caml_socket_read"
  external close: [`ro_file] fd -> unit = "caml_socket_close"

  (* As fdbind, except on functions that will either be Some or None *)
  let rec iobind iofn arg =
    match iofn arg with
    |OK x -> return x
    |Err err -> fail (Error err)
    |Retry -> assert false
end
