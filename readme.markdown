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
still bugs lurking somewhere in it. I have only tested it with emacs 24.5: I am
not doing anything fancy so it *should* work with older versions (but I cannot
guarantee it).

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
simpler but I suspect handling backslashes correctly would be much harder. The
syntax highlighting could probably be written better. If your workflow would
benefit from new functions (tree-like navigation like in `org-mode`, snippets,
etc), then please let me know.

Additionally, if you can make a weird enough parameter file that this mode
highlights, indents, or navigates it incorrectly, please send it my way.

I have written some simple tests (and these did catch two new bugs) with `ERT`
that cover basic indentation and navigation occurrences. I am not sure how to
write tests for syntax highlighting; no matter what I try buffers created with
`with-temp-buffer` do not ever do syntax highlighting. I would be very
appreciative if someone could instruct me on how to make such a test.

## Bugs that will probably not be fixed

### comment handling

Since `prm-mode` is derived from `prog-mode` (the generic major programming mode
for emacs), `prm-mode` treats comments differently from the parser in
`ParameterHandler`. For example, `prm-mode` highlights backslashed comments as
```sh
   set foo = bar # proper comment
   set baz = \# some escaped comment
```

but, if I understand it correctly, `ParameterHandler` does not bother with
backslashes in front of `#` and will just remove `#some escaped comment` from
the line before setting the value of `baz`.

One could argue that this is a bug in `ParameterHandler`, but if no one over the
last fifteen years has needed to get a `#` into a string, then it is probably
not worth worrying over.

### Syntax highlighting in continuations

Most emacs modes do this 'incorrectly'; if a line starts with a keyword, then
that keyword will be highlighted, regardless of whether or not the last line
ended in a `\`. Similarly, as far as my experiments can tell, emacs can only
highlight constructions on a single line, so multi-line (with continuation)
section headings are improperly highlighted.

## A screenshot

This is what `prm-mode` looks like in emacs, with a slight variation on the
`comida` theme:

<img src="./screenshots/comida-prm-mode.png" width="500"/>
