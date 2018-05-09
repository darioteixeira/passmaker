Passmaker
=========

The Passmaker project consists of a passphrase generator library and a
command line utility named `passmakercmd`.  It enables the generation of
memorable passphrases with 32 or 64 bits of entropy.

Bitcoin's
[BIP38](https://github.com/bitcoin/bips/blob/master/bip-0038.mediawiki) and
[BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki)
are two well-known applications where good passphrases with sufficient
entropy are vital for security.  Unfortunately, humans are notoriously bad
at coming up with secure passphrases.  Moreover, many passphrase generators
produce sequences of random words which are hard to memorise.  The goal
of Passmaker is to produce passphrases with a known entropy (either 32 or
64 bits), but whose words are arranged in a grammatically sensible order,
and are thus easier to memorise.

Note that for most applications, 32 (and even 64) bits of entropy
do not provide enough security **on their own**.  Therefore, in the
[BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki)
application, a passphrase generated by Passmaker is intended to be used as
the optional passphrase that further protects the traditional 12 or 24 word
(128 or 256 bits, respectively) mnemonic phrase, and **not** as a substitute.


Passphrase structure
--------------------

All passphrases have a fixed grammatical structure:

 - **32-bit phrases**: `adjective + noun + [from] + location`.
 - **64-bit phrases**: `adjective + noun + verb + adjective + noun + [from] + location`.

The `from` preposition is always output by Passmaker, but is optional in the
commands where a passphrase is used as input.  You may also use the article
`the` before a noun phrase whenever a passphrase is given as input, and the
article(s) will likewise be ignored.  Note also that Passmaker capitalises
the first character of output passphrases, and does the same for locations.
However, case is ignored when passphrases are used as input.

The entropy contribution from each word category is as follows:

 - **Adjective**: 11 bits (from a list of 2048 words).
 - **Noun**: 11 bits (from a list of 2048 words).
 - **Verb**: 10 bits (from a list of 1024 words).
 - **Location**: 10 bits (from a list of 1024 words).

All word lists obey the following rules:

 - No word must be more than ten characters in length.

 - The edit distance between any two words **within the same category** must be
   at least **two** using the Levenshtein-Damerau measure.  This enables the
   guaranteed detection of simple spelling mistakes, and allows the program
   to provide meaningful suggestions for the misspelled word.

 - No two words **within the same category** may share the same four-letter
   prefix. This follows the same convention as
   [Bitcoin BIP-39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki),
   and allows the passphrase to be stored on devices such as [Cryptosteel](https://cryptosteel.com/).

Furthermore, special considerations were taken for each word category:

 - The list of adjectives includes present and past participles of verbs.

 - It must not require too much effort to ascribe agency to the nouns.
   Therefore, animal and plant names, professions, and physical objects
   are over-represented.

 - Verbs must be transitive, otherwise the generated passphrase makes
   no grammatical sense.

 - Locations include cities, countries, regions, celestial objects, and
   even historical and fictional places. Being at least somewhat recognisable
   was the main criterion for inclusion, but the resulting list has an obvious
   bias towards Western cultures. Therefore, though the list ommits some large
   Chinese cities which hardly anyone in the West has ever heard of, it does
   include small cities much more familiar to European or American ears.


Installation
------------

The passmaker library and associated command line utility are available in
[OPAM](https://opam.ocaml.org/).  Just install packages `passmaker` and
`passmakercmd`, respectively.


Using the command line utility
------------------------------

You can generate a fresh 64-bit passphrase with the `generate` command.  The entropy
is fetched from `/dev/urandom`, which is considered a cryptographically secure source:

```
$ passmakercmd generate

Absurd pirate dislikes hidden lottery from Madrid
```

Generating a 32-bit passphrase requires setting the `size` parameter:

```
$ passmakercmd generate --size 32

Demanding reptile from Bordeaux
```

The `abbreviate` command takes a full text passphrase as input and outputs
the four-letter abbreviation of each word. Note that the `from` preposition
is dropped:

```
$ passmakercmd abbreviate "Absurd pirate dislikes hidden lottery from Madrid"

absu pira disl hidd lott madr
```

Conversely, the `expand` command takes an abbreviated passphrase as input
and expands it into its full text representation:

```
$ passmakercmd expand "absu pira disl hidd lott madr"

Absurd pirate dislikes hidden lottery from Madrid
```

The command `hex-of-text` converts a full text passphrase into its hexadecimal
representation:

```
$ passmakercmd hex-of-text "Absurd pirate dislikes hidden lottery from Madrid"

8aa0b31738aa600b
```

Conversely, the command `text-of-hex` converts a hexadecimal representation of
a passphrase into full text:

```
$ passmakercmd text-of-hex 8aa0b31738aa600b

Absurd pirate dislikes hidden lottery from Madrid
```

Recall that the preposition `from` before the location and the article
`the` before a noun phrase are automatically discarded when converting a
text passphrase into its hexadecimal or abbreviated form. Therefore, the
following invocations all produce the same output:

```
$ passmakercmd hex-of-text ""bsurd pirate dislikes hidden lottery Madrid

8aa0b31738aa600b

$ passmakercmd hex-of-text "Absurd pirate dislikes hidden lottery from Madrid"

8aa0b31738aa600b

$ passmakercmd hex-of-text "The absurd pirate dislikes the hidden lottery from Madrid"

8aa0b31738aa600b
```

Finally, all commands that expected a positional parameter will read from standard
input if that parameter is not present in the command line.  This enables using
the utility in a pipeline:

```
$ echo 8aa0b31738aa600b | passmakercmd text-of-hex | passmakercmd abbreviate

absu pira disl hidd lott madr
```


Frequently Asked Questions
--------------------------

**Q:** The generated passphrase was offensive! What's up with that?

**A:** Some care was taken to remove potentially offensive words from the word lists.
However, given that upwards of 16 quintillion passphrases may be generated, there
are bound to be some that someone, somewhere, will find offensive.  Should that be
you, just chill and generate a new passphrase.
