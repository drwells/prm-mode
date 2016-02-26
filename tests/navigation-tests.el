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

;; Tests for navigation by `prm-next-subsection' and `prm-previous-subsection'.

(require 'ert)
(require 'prm-mode)

(ert-deftest subsection-navigation-capitalization-01 ()
  "Test that improperly capitalized `subsection's (e.g.,
`Subsection') are skipped during subsection naviagation."
  (should
   (= 123
      (with-temp-buffer
        (prm-mode)
        (insert-file-contents "test-files/subsection-capitalization-01.prm")
        (goto-char (point-min))
        (prm-next-subsection)
        (point)))))

(ert-deftest subsection-navigation-backslash-01 ()
  "Test that a line containing `subsection' appearing in a
continuation is skipped during subsection naviagation."
  (should
   (= 379
      (with-temp-buffer
        (prm-mode)
        (insert-file-contents "test-files/subsection-navigation-backslash-01.prm")
        (goto-char 18)
        (prm-next-subsection)
        (point)))))

(ert-deftest subsection-navigation-cycle-01 ()
  "Test that we properly cycle back to the top of the buffer
during subsection navigation."
  (should
   (= 86
      (with-temp-buffer
        (prm-mode)
        (insert-file-contents "test-files/subsection-navigation-cycle-01.prm")
        (goto-char 103)       ;; at line 8
        (prm-next-subsection) ;; at line 14
        (prm-next-subsection) ;; at line 1
        (prm-next-subsection) ;; at line 7
        (point)))))

(ert-deftest subsection-navigation-cycle-02 ()
  "Test that we properly cycle back to the bottom of the buffer
during subsection navigation."
  (should
   (= 189
      (with-temp-buffer
        (prm-mode)
        (insert-file-contents "test-files/subsection-navigation-cycle-01.prm")
        (goto-char 103)           ;; at line 8
        (prm-previous-subsection) ;; at line 7
        (prm-previous-subsection) ;; at line 1
        (prm-previous-subsection) ;; at line 14
        (point)))))
