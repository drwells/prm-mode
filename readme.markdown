# prm-mode.el : a mode for deal.II parameter files

## Overview

I wrote this mode to scratch a long-time itch: there is no nice support for
syntax highlighting or navigation in deal.II parameter files available for
emacs. This small mode supports:

* Navigation between `subsection`s with `M-p` and `M-n`
* Syntax highlighting
* automatic indentation (standard, not with `electric-mode`)

*This mode is not yet done!* It seems to work correctly for a couple of sample
files (i.e., some of the large parameter files in ASPECT) but there are surely
still bugs lurking somewhere in it. In particular, I have not looked into
dependencies: This mode does `require` anything but probably should. I have only
tested it with emacs 24.5: I am not doing anything fancy so it *should* work
with older versions (but I cannot guarantee it).

## How to set it up

Standard stuff for emacs: add this to your init file:
```elisp
(require 'prm-mode "~/path-to-prm-mode/prm-mode.el" nil)
(add-to-list 'auto-mode-alist '("/*.\.prm$" . prm-mode))
```
`package.el` support is on the TODO list.

The customization support is present but not well documented. If you look
through the source you should see:
```elisp
;; user configurable variables
(defvar prm-continuation-line-extra-indentation
  4
  "Amount of extra indentation to give continuation lines.")

(defvar prm-subsection-indentation-level
  2
  "Amount of indentation to use in subsections.")

(defvar prm-permit-subsection-cycling
  t
  "Whether or not to cycle through the buffer when searching for
  subsections.")
```

which are the three current customization options.

## Relevant work

This mode is partly inspired by @davydden's syntax highlighting mode for Atom
available [here](https://github.com/davydden/language-dealii-prm). We can't
let the new editor on the block to have all the fun :)

## How to help

I would greatly appreciate assistance with this mode. I think the indentation
code is probably fine the way it is; using `smie` would probably make most of it
simpler but I suspect handling backslashes correctly would be much harder.  The
syntax highlighting could probably be written better (using `regexp-opt` is also
on the TODO list) and I have no idea how to write tests for emacs modes (though
I know this is possible and regularly done).
