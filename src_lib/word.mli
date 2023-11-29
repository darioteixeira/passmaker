open Prelude


(********************************************************************************)
(** {1 Module types}                                                            *)
(********************************************************************************)

module type S =
sig
    type t

    val name: string
    val count: int

    val of_int: int -> t
    val to_int: t -> int

    val of_string: string -> t option
    val to_string: t -> string

    val of_abbr_string: string -> t option
    val to_abbr_string: t -> string

    val suggest: max_distance:int -> string -> string option * string list array

    include TESTABLE with type t := t
end


(********************************************************************************)
(** {1 Modules encapsulating word lists}                                        *)
(********************************************************************************)

module Adjective: S
module Location: S
module Noun: S
module Verb: S
