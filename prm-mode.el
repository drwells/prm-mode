;;; prm-mode.el --- A deal.II parameter file mode for emacs.

;; Copyright (C) 2016 David Wells

;; Author: David Wells
;; Version: 0.4
;; Keywords: deal.II

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

;; A simple mode for deal.II parameter files that handles syntax highlighting
;; and indentation.

;; constants and various internals
(defconst prm-version 0.4
  "beta copy of prm-mode.")

(defun prm--either-case-regexp (expression)
  "Internal function: given a string, return a regular expression
that matches the purely upper case or purely lower case versions
of that string."
  (regexp-opt (list (upcase expression) (downcase expression)) t))

(defconst prm--case-independent-subsection
  (prm--either-case-regexp "subsection")
  "Regular expression matching SUBSECTION or subsection.")

(defconst prm--case-independent-end
  (prm--either-case-regexp "end")
  "Regular expression matching END or end.")

(defconst prm-font-lock-sectioning
  (list
   ;; For reasons I do not fully understand, emacs needs both cases (a
   ;; subsection with and without a trailing comment) to highlight things
   ;; correctly.
   (list (concat "^[ \\t]*" prm--case-independent-subsection " \\(.*\\)$")
         2
         font-lock-variable-name-face)
   (list (concat "^[ \\t]*" prm--case-independent-subsection " \\(.*\\)#.*$")
         2
         font-lock-variable-name-face)
   (list (concat "^[ \\t]*" prm--case-independent-subsection " ")
         1
         font-lock-keyword-face)
   (list (concat "^[ \\t]*" prm--case-independent-end)
         1
         font-lock-keyword-face))
  "List containing the sectioning words for a .prm file.")

(defconst prm-font-lock-commands
  (list
   (list (concat "^[ \\t]*" (prm--either-case-regexp "include") " ")
         1
         font-lock-builtin-face)
   (list (concat "^[ \\t]*" (prm--either-case-regexp "set") " ")
         1
         font-lock-builtin-face))
  "List containing the command words for a .prm file.")

(defconst prm--blank-line "^[ \\t]*$")


(defvar prm-syntax-table
  (let ((prm-mode-syntax-table (make-syntax-table)))
    (modify-syntax-entry ?# "< b" prm-mode-syntax-table)
    (modify-syntax-entry ?\n "> b" prm-mode-syntax-table)
    prm-mode-syntax-table)
  "Syntax table for prm mode.")

(defvar prm-font-lock-keywords
  (append prm-font-lock-sectioning
          prm-font-lock-commands)
  "Default highlighting expressions for prm mode.")

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

;; internal indentation parsing functions
(defun prm--current-line-ends-in-backslash ()
  "Internal function checking whether or not the current line
ends with a backslash. This does not check for multiple
backslashes (i.e., ending a line with two backslashes is still a
continuation) because ParameterHandler does not."
    (save-excursion
      (beginning-of-line)
      (looking-at ".*\\\\ *$")))


(defun prm--current-line-starts-continuation ()
  "Internal function checking whether or not the current line
starts a continuation."
  (and
   (prm--current-line-ends-in-backslash)
   (save-excursion
     (beginning-of-line)
     (if (bobp)
         t
       (progn
         (forward-line -1)
         (not (prm--current-line-ends-in-backslash)))))))


(defun prm--current-line-ends-continuation ()
  "Internal function checking whether or not the current line
finishes a continuation."
  (save-excursion
    (beginning-of-line)
    (if (bobp)
        nil ;; If we are at the beginning we can't end a continuation
        (if (prm--current-line-ends-in-backslash)
            nil ;; if we end in '\' then we are in the middle
          (progn
            (forward-line -1)
            (if (prm--current-line-ends-in-backslash)
                t ;; previous line ends in '\' and the starting line does not,
                  ;; so the starting line ends a continuation
              nil))))))


(defun prm--indent-from-last-logical-line ()
  "Internal function returning the indentation of the last
non-blank logical line (that is, ignoring the indentation of
continuation lines)."
  (save-excursion
    (if
     (bobp) (current-indentation)
     (save-excursion
       (forward-line -1)
       ;; traverse blank lines
       (while (and (looking-at prm--blank-line) (not (bobp)))
         (forward-line -1))
       (if (prm--current-line-ends-continuation)
           (progn
             (forward-line -1)
             (while (and (prm--current-line-ends-in-backslash)
                         (not (prm--current-line-starts-continuation)))
               (forward-line -1))
             ;; special case: if we are at a subsection, then return with offset
             (if (prm--current-line-contains-valid-subsection)
                 (+ (current-indentation)
                    prm-subsection-indentation-level)
               (current-indentation)))
         ;; same
         (if (prm--current-line-contains-valid-subsection)
             (+ (current-indentation)
                prm-subsection-indentation-level)
           (current-indentation)))))))


(defun prm--current-line-contains-valid-sectioning-statement
    (sectioning-statement)
  "Internal function; return `t' if the current line starts a new
subsection or end statement (i.e., the previous line is not a
continuation and this line begins with the given sectioning
statement) and return `nil' otherwise."
  (save-excursion
    ;; see the note in prm-indent-current-line on case-fold-search for the
    ;; rationale
    (let ((case-fold-search nil)
          (prm--at-sectioning-statement-p
           (lambda () (looking-at (concat "^[ \\t]*" sectioning-statement)))))
      (beginning-of-line)
      ;; if we are at the beginning, then check if we have a statement.
      ;; Beginning the file with an 'end' does not make sense but allow it here
      ;; anyway
      (if (bobp)
          (funcall prm--at-sectioning-statement-p)
        ;; Otherwise, ensure that the previous line did not end in a backslash.
        (progn
          (forward-line -1)
          (if (prm--current-line-ends-in-backslash)
              nil
            (progn
              (forward-line 1)
              (funcall prm--at-sectioning-statement-p))))))))


(defun prm--current-line-contains-valid-subsection ()
  "Internal function; return `t' if the current line contains a
valid subsection statement and `nil' otherwise."
  (prm--current-line-contains-valid-sectioning-statement
   (prm--either-case-regexp "subsection")))


(defun prm--current-line-contains-valid-end ()
  "Internal function; return `t' if the current line contains a
valid end statement and `nil' otherwise."
  (prm--current-line-contains-valid-sectioning-statement
   (prm--either-case-regexp "end")))


(defun prm--matching-subsection-indentation ()
  "Internal function; Assuming that the cursor is currently at an
'end' sectioning command, return the indentation level of the
current subsection."
  (save-excursion
    (let ((stack-count 1))
    (while (and (not (bobp)) (not (eq stack-count 0)))
      (forward-line -1)
      (beginning-of-line)
      (if (prm--current-line-contains-valid-subsection)
          (setq stack-count (1- stack-count))
        (if (prm--current-line-contains-valid-end)
            (setq stack-count (1+ stack-count)))))
    (current-indentation))))


(defun prm-indent-current-line ()
  "Indent the current line. This just defaults to calling
`prm--indent-from-last-logical-line' most of the time."
  (interactive)
  ;; Note that, annoyingly, looking-at is case-insensitive by default, which
  ;; screws up indentation because it allows 'enD' and 'EnD' and other such
  ;; things to be treated the same as 'end'. Hence, temporarily disable
  ;; case-fold-search.
  (let ((case-fold-search nil)
        (target-indent-value 0)
        (previous-line-indentation-level (save-excursion
                                           (forward-line -1)
                                           (current-indentation)))
        (initial-indentation (current-indentation))
        (initial-point (point)))
    (save-excursion
      (beginning-of-line)
      (cond
       ;; if we are indenting the first line then do nothing
       ((bobp)
        (setq target-indent-value (current-indentation)))
       ;; see if we start a continuation: this requires extra indenting
       ((save-excursion
          (forward-line -1)
          (prm--current-line-starts-continuation))
        (progn
          (setq target-indent-value (+ previous-line-indentation-level
                                       prm-continuation-line-extra-indentation))))
       ;; if we are in the middle of a continuation, keep indenting by the same amount
       ((save-excursion
          (forward-line -1)
          (prm--current-line-ends-in-backslash))
        (progn
          (setq target-indent-value previous-line-indentation-level)))
       ;; We may now assume that the current line is not a continuation since the
       ;; last line did not end with a '\'.
       ;;
       ;; If we are at an 'end' statement, then match the indentation with the
       ;; opening 'subsection' statement.
       ((prm--current-line-contains-valid-end)
        (progn
          (setq target-indent-value (prm--matching-subsection-indentation))))
       ;; permit any number of blank lines and capture everything else. This
       ;; includes opening subsections.
       (t
        (progn
          (setq target-indent-value (prm--indent-from-last-logical-line))))))
    (indent-line-to target-indent-value)
    ;; If we indented a line that already had content on it, restore the
    ;; relative position of the cursor. Otherwise keep the cursor where it is
    ;; (indent-line-to puts it at the end of the indentation).
    (if (= (point)
           (save-excursion
             (end-of-line)
             (point)))
        (point)
      (goto-char (+ initial-point (- target-indent-value initial-indentation))))))


;; navigation functions
(defun prm--check-direction (direction)
  "Internal function checking the value of the symbol `direction';
it should be `up' or `down'."
  (if (and (not (eq direction 'up))
           (not (eq direction 'down)))
      (error "The argument `direction' should be either `up' or `down'.")))


(defun prm--find-subsection (direction)
  "Internal function returning the point value of the next
subsection in either the `up' or `down' direction. Return `nil'
if no such subsection may be found (without cycling)."
  (prm--check-direction direction)
  (save-excursion
    (let ((subsection-point nil)
          (line-increment (if (eq direction 'up) -1 1))
          (at-boundary-p (if (eq direction 'up) 'bobp 'eobp)))
      ;; bail out if we are at the beginning and going up: there can be no next
      ;; subsection in this case
      (beginning-of-line)
      (if (and (bobp) (eq direction 'up))
          nil
        (progn
          ;; move one line to make sure we do not return the current subsection
          (forward-line line-increment)
          (if (prm--current-line-contains-valid-subsection)
              (+ (point) (current-indentation))
            (progn
              (while (and (not (funcall at-boundary-p))
                          (not (prm--current-line-contains-valid-subsection)))
                (forward-line line-increment))
              ;; we have either reached a boundary or a subsection; a boundary
              ;; may also be a subsection.
              (if (funcall at-boundary-p)
                  (if (prm--current-line-contains-valid-subsection)
                      (+ (point) (current-indentation))
                    nil)
                (+ (point) (current-indentation))))))))))


(defun prm--travel-subsection (direction)
  "Internal function to handle previous and next subsections."
  (prm--check-direction direction)
  (let ((subsection-point (prm--find-subsection direction))
        (goto-cycle-boundary (if (eq direction 'up)
                                 (lambda () (goto-char (point-max)))
                               (lambda () (goto-char (point-min))))))
    (if (not (eq subsection-point nil))
        (goto-char subsection-point)
      ;; otherwise, if enabled, go to the correct side of the buffer and try
      ;; again
      (if prm-permit-subsection-cycling
          (progn
            (save-excursion
              (funcall goto-cycle-boundary)
              (setq subsection-point
                    ;; check if we just arrived at a subsection.
                    (if (prm--current-line-contains-valid-subsection)
                        (+ (point) (current-indentation))
                      (prm--find-subsection direction))))
            (if (not (eq subsection-point nil))
                (goto-char subsection-point)))))))


(defun prm-next-subsection ()
  "Move the cursor to the beginning of the next subsection, if
one exists."
  (interactive)
  (prm--travel-subsection 'down))


(defun prm-previous-subsection ()
  "Move the cursor to the beginning of the previous subsection."
  (interactive)
  (prm--travel-subsection 'up))


(defun prm-fill-paragraph (&optional justify region)
  "Instruct fill-paragraph to do nothing when not in a comment block."
  (let ((initial-point (point)))
    (save-excursion
      (beginning-of-line)
      ;; search for the start of a valid comment: may contain an even number of
      ;; backslashes before the '#'. Search up to (and including) the initial
      ;; point
      (if (or (re-search-forward "^#" (+ initial-point 1) t)
              (re-search-forward "[^\\]\\(\\\\\\\\\\)*#" (+ initial-point 1) t))
          ;; note the weird convention: return 'nil' to continue indenting,
          ;; return t to do nothing.
          (progn
            nil)
        (progn
          t)))))

(defvar prm-mode-hook nil)

(defvar prm-mode-map
  (let ((prm--map (make-keymap)))
    (define-key prm--map "\C-j" 'newline-and-indent)
    prm--map)
  "Keymap for prm mode.")

(define-derived-mode prm-mode prog-mode "prm"
  "Major mode for editing deal.II parameter files.
\\{prm-mode-map\}"
  :syntax-table prm-syntax-table
  (progn
    (setq comment-start "#")
    (setq comment-end "")
    (setq mode-name "prm-mode")
    (use-local-map prm-mode-map)
    ;; TODO figure out why these can't be put in the map
    (local-set-key (kbd "M-p") 'prm-previous-subsection)
    (local-set-key (kbd "M-n") 'prm-next-subsection)
    (set (make-local-variable 'font-lock-defaults) '(prm-font-lock-keywords))
    (set (make-local-variable 'indent-line-function) #'prm-indent-current-line)
    (set (make-local-variable 'fill-paragraph-function) #'prm-fill-paragraph)
    (set (make-local-variable 'adaptive-fill-regexp) nil)
    (setq major-mode 'prm-mode)))

(provide 'prm-mode)
;;; prm-mode.el ends here
