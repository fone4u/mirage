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


external alloc_external_string: int -> string = "caml_alloc_external_string"
external chunk_external_string: string -> int * int = "caml_chunk_string_pages"

let free_list = Queue.create ()

let alloc ~nr_pages =
  let buf = alloc_external_string ((nr_pages+1) * 4096) in
  let off, nr = chunk_external_string buf in
  assert (nr = nr_pages);
  let off = off * 8 in (* bitstrings offsets are in bits *)
  let page_size = 4096 * 8 in (* PAGE_SIZE==4096, in bits *)
  for i = 0 to nr_pages - 1 do
    let bs = buf, (off + (i*page_size)), page_size in
    Queue.add bs free_list;
  done

let rec get_free () =
  try
    Queue.pop free_list
  with Queue.Empty -> begin
    alloc ~nr_pages:128;
    get_free ()
  end

let put_free bs =
  (* TODO: assert that the buf is a page aligned one we allocated above *)
  Queue.add bs free_list
