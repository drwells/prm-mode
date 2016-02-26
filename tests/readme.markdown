# prm-mode tests

`prm-mode` comes with a small testsuite that check some of the indentation and
navigation functionality of the mode. You can run all tests from the shell with

```
$ make test
```

in this directory. Alternatively, one can use the command (which is exactly what
is in the `Makefile`)

```
$ emacs -Q -batch -L ../ -l ert -l tests.el -f ert-run-tests-batch-and-exit
```

*Please send me any parameter files that are not handled correctly! More test
 cases are needed.*

# about `ERT`

Newer emacsen come with `ERT`, the 'Emacs Lisp Regression Testing' library. All
of the tests in `prm-mode` do approximately the following:
1. create a temporary buffer and dump a known parameter file into it.
2. Either move the point (via `prm-next-subsection` or similar) or insert
   content.
3. Check that the point is where it should be and that any new content was
   indented correctly.
