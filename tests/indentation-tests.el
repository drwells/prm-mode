;;; prm-mode/tests/navigation-tests.el

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

;; Tests for indentation.

(require 'ert)
(require 'prm-mode)

(ert-deftest indent-nested-subsection-01 ()
  "Test that nested subsections are properly indented."
  (should
   (string=
    (with-temp-buffer
      (prm-mode)
      (setq prm-subsection-indentation-level 2)
      (insert-file-contents "test-files/indent-nested-subsection-01.prm")
      (indent-region (point-min) (point-max))
      (buffer-string))
    (with-temp-buffer
      (insert-file-contents "test-files/indent-nested-subsection-01.prm.out")
      (buffer-string)))))

(ert-deftest indent-end-01 ()
  "Test that inserted 'end' statements are properly indented when
one hits TAB."
  (should
   (=
    2
    (with-temp-buffer
      (prm-mode)
      (setq prm-subsection-indentation-level 2)
      (insert-file-contents "test-files/half-subsection.prm")
      (goto-char 53)
      (newline-and-indent)
      (insert "end")
      (indent-for-tab-command)
      (current-indentation)))))

(ert-deftest indent-end-02 ()
  "Test that inserted 'end' statements are properly indented when
one hits RET."
  (should
   (=
    2
    (with-temp-buffer
      (prm-mode)
      (setq prm-subsection-indentation-level 2)
      (insert-file-contents "test-files/half-subsection.prm")
      (goto-char 53)
      (newline-and-indent)
      (insert "end")
      (newline-and-indent)
      (current-indentation)))))

(ert-deftest indent-continuation-at-bob ()
  "Ensure that continuations are correctly indented at the
beginning of the buffer."
  (should
   (string=
    (with-temp-buffer
      (prm-mode)
      (setq prm-subsection-indentation-level 2)
      (setq prm-continuation-line-extra-indentation 4)
      (insert-file-contents "test-files/bob-continuation.prm")
      (goto-char 26)
      (newline-and-indent)
      (insert "baz")
      (newline-and-indent)
      (insert "set foo = bar")
      (newline-and-indent)
      (insert "END")
      (indent-for-tab-command)
      (buffer-string))
    (with-temp-buffer
      (insert-file-contents "test-files/bob-continuation.prm.out")
      (buffer-string)))))

(ert-deftest indent-continuation-01 ()
  "Test that the first continuation line is correctly indented."
  (should
   (=
    8
    (with-temp-buffer
      (prm-mode)
      (setq prm-subsection-indentation-level 2)
      (setq prm-continuation-line-extra-indentation 4)
      (insert-file-contents "test-files/start-continuation.prm")
      (goto-char 63)
      (newline-and-indent)
      (insert "baz")
      (current-indentation)))))

(ert-deftest indent-continuation-02 ()
  "Test that the second continuation line is correctly indented."
  (should
   (=
    8
    (with-temp-buffer
      (prm-mode)
      (setq prm-subsection-indentation-level 2)
      (setq prm-continuation-line-extra-indentation 4)
      (insert-file-contents "test-files/continue-continuation.prm")
      (goto-char 77)
      (newline-and-indent)
      (current-indentation)))))

(ert-deftest indent-after-continuation-01 ()
  "Test that the line after a continuation is correctly
indented."
  (should
   (=
    4
    (with-temp-buffer
      (prm-mode)
      (setq prm-subsection-indentation-level 2)
      (setq prm-continuation-line-extra-indentation 4)
      (insert-file-contents "test-files/continue-continuation.prm")
      (goto-char 77)
      (newline-and-indent)
      (insert "baz")
      (newline-and-indent)
      (insert "baz")
      (current-indentation)))))
