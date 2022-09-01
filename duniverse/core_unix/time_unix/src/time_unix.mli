open! Core
open! Import
module Time := Core.Time
include Time_functor_intf.S with module Time0 := Time and module Time := Time

module Stable : sig
  module V1 : sig
    type nonrec t = t [@@deriving hash, typerep]
    type nonrec comparator_witness = comparator_witness

    include
      Stable_comparable.V1
      with type t := t
      with type comparator_witness := comparator_witness
  end

  (** Provides a sexp representation that is independent of the time zone of the machine
      writing it.
      [V1.t_of_sexp] will be generous in what sexps it accepts, while [V2.t_of_sexp]
      should not be expected to parse sexps not generated by [V2.sexp_of_t]
  *)
  module With_utc_sexp : sig
    module V1 :
      Stable_comparable.V1
      with type t = t
      with type comparator_witness = comparator_witness

    module V2 : sig
      type nonrec t = t [@@deriving hash]
      type nonrec comparator_witness = comparator_witness

      include
        Stable_comparable.V1
        with type t := t
        with type comparator_witness := comparator_witness
    end
  end

  (** Provides a sexp representation where all sexps must include a timezone (in contrast
      to [V1] above, which will assume local timezone if it's not specified). When
      serializing, it uses the local timezone.  Concretely, this is just [V1] but
      [t_of_sexp] is replaced with [t_of_sexp_abs]. *)
  module With_t_of_sexp_abs : sig
    module V1 : sig
      type nonrec t = t
      type nonrec comparator_witness = comparator_witness

      include Stable with type t := t with type comparator_witness := comparator_witness
    end
  end

  module Span : sig
    module V1 : sig
      type t = Time.Stable.Span.V1.t [@@deriving hash, equal]

      include Stable_without_comparator with type t := t
    end

    module V2 : sig
      type t = Time.Stable.Span.V2.t [@@deriving hash, equal]

      include Stable_without_comparator with type t := t
    end

    module V3 : sig
      type t = Time.Stable.Span.V3.t [@@deriving hash, typerep, equal]

      include Stable_without_comparator with type t := t
    end
  end

  module Ofday : sig
    module V1 : sig
      type t = Time.Stable.Ofday.V1.t [@@deriving hash]

      include Stable_without_comparator with type t := t
    end

    module Zoned : sig
      module V1 : sig

        (** This uses [With_nonchronological_compare.compare]. *)
        type t = Ofday.Zoned.t [@@deriving hash]

        include Stable_without_comparator with type t := t
      end
    end
  end

  module Zone : sig
    module V1 : sig
      type t = Timezone.Stable.V1.t [@@deriving hash]

      include Stable_without_comparator with type t := t
    end

    module Full_data : sig
      module V1 : Stable_without_comparator with type t = Time.Stable.Zone.Full_data.V1.t
    end
  end
end
