;;; prm-mode/tests/tests.el --- A deal.II parameter file mode for emacs.

;; Copyright (C) 2016 David Wells

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; One file which loads all other elisp test files. This enables one to run all
;; tests from the command line by loading this file with emacs in batch mode
;; (see the Makefile).

(load-file "navigation-tests.el")
(load-file "indentation-tests.el")

;; tests.el ends here
