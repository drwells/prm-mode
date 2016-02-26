### prm-mode/tests/Makefile

## Copyright (C) 2016 David Wells

## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.

## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.

## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

### Commentary:

## This Makefile lets users run the tests for prm-mode from the command line
## with the command `make test'.

# explanation of options:
# -Q          : do not load any configuration files
# -batch      : run non-interactively
# -L ../      : include the above directory (which contains prm-mode.el)
# -l ert      : run with ert (emacs regression testing)
# -l tests.el : run the master test file
# -f (...)    : call the elisp function ert-run-tests-batch-and-exit
test:
	emacs -Q -batch -L ../ -l ert -l tests.el -f ert-run-tests-batch-and-exit
