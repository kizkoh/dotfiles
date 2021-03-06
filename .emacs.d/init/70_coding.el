;;; 70_coding.el - Mode configure in coding

;;; Code:

;;; Git Gutter
(require 'git-gutter-fringe)
(global-git-gutter-mode)

(set-face-foreground 'git-gutter-fr:modified "yellow")
(set-face-foreground 'git-gutter-fr:added    "lightgreen")
(set-face-foreground 'git-gutter-fr:deleted  "white")

  (eval-after-load 'git-gutter
    '(progn
       ;;; Jump between hunks
       (global-set-key (kbd "C-x n") 'git-gutter:next-hunk)
       (global-set-key (kbd "C-x p") 'git-gutter:previous-hunk)

       ;;; Act on hunks
       (global-set-key (kbd "C-x v =") 'git-gutter:show-hunk)
       (global-set-key (kbd "C-x r") 'git-gutter:revert-hunks)
       ;; Stage hunk at point.
       ;; If region is active, stage all hunk lines within the region.
       (global-set-key (kbd "C-x t") 'git-gutter:stage-hunks)
       (global-set-key (kbd "C-x c") 'git-gutter:commit)
       (global-set-key (kbd "C-x C") 'git-gutter:stage-and-commit)
       (global-set-key (kbd "C-x C-y") 'git-gutte:stage-and-commit-whole-buffer)
       (global-set-key (kbd "C-x U") 'git-gutter:unstage-whole-buffer)))

;;; Flycheck
(add-hook 'after-init-hook #'global-flycheck-mode)
;; (eval-after-load 'flycheck
;;   '(custom-set-variables
;;     '(flycheck-display-errors-function #'flycheck-pos-tip-error-messages)))
(setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc python-pycompile))

;;; Agda-mode
;; (load-library "agda2")

;;; C/Cpp mode
;; Configure pre-compile header
(require 'irony)
(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'objc-mode-hook 'irony-mode)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
(add-to-list 'company-backends 'company-irony)

(setq irony-lang-compile-option-alist
      (quote ((c++-mode . "c++ -std=c++11 -lstdc++")
              (c-mode . "c")
              (objc-mode . "objective-c"))))

(defun ad-irony--lang-compile-option ()
  (defvar irony-lang-compile-option-alist)
  (let ((it (cdr-safe (assq major-mode irony-lang-compile-option-alist))))
    (when it (append '("-x") (split-string it "\s")))))
(advice-add 'irony--lang-compile-option :override #'ad-irony--lang-compile-option)

;;; Ebuild-mode
(add-to-list 'load-path "@SITELISP@")
(autoload 'ebuild-mode "ebuild-mode" nil t)
(add-to-list 'auto-mode-alist
	     '("\\.\\(ebuild\\|eclass\\|eblit\\)\\'" . ebuild-mode))
(autoload 'gentoo-newsitem-mode "gentoo-newsitem-mode" nil t)
(add-to-list 'auto-mode-alist
	     '("/[0-9]\\{4\\}-[01][0-9]-[0-3][0-9]-.+\\.[a-z]\\{2\\}\\.txt\\'"
	       . gentoo-newsitem-mode))
(add-to-list 'interpreter-mode-alist '("runscript" . sh-mode))
(modify-coding-system-alist 'file "\\.\\(ebuild\\|eclass\\|eblit\\)\\'" 'utf-8)

;;; Terraform-mode
(autoload 'terraform-mode "terraform-mode" "terraform editing mode." t)
(add-to-list 'auto-mode-alist '("\\.tf$" . terraform-mode))

;;; Go-mode
(require 'go-autocomplete)
(require 'auto-complete-config)
(require 'go-eldoc)
(add-hook 'before-save-hook 'gofmt-before-save)

;;; Lua-mode
(autoload 'lua-mode "lua-mode" "Lua editing mode." t)
(add-to-list 'auto-mode-alist '("\\.lua$" . lua-mode))
(add-to-list 'interpreter-mode-alist '("lua" . lua-mode))

;;; Haskell-mode
(require 'haskell-mode)
(require 'haskell-cabal)
(add-to-list 'auto-mode-alist '("\\.hs$" . haskell-mode))
(add-to-list 'auto-mode-alist '("\\.lhs$" . literate-haskell-mode))
(add-to-list 'auto-mode-alist '("\\.cabal\\'" . haskell-cabal-mode))
(defvar haskell-program-name "/usr/bin/ghci")
(defvar haskell-ghci-command "main")
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
(add-hook 'haskell-mode-hook 'turn-on-haskell-font-lock)

;;; Java-mode
(add-hook 'java-mode-hook
	  (lambda ()
	    (setq indent-tabs-mode nil)
	    (defvar c-basic-offset 4)))

;;; Javascript-mode
(require 'prettier-js)
(add-hook 'js2-mode-hook 'prettier-js-mode)
(add-hook 'web-mode-hook 'prettier-js-mode)

;;; Typescript-mode
(require 'typescript-mode)
(require 'tide)
(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  (company-mode +1))

(setq company-tooltip-align-annotations t)
(add-hook 'before-save-hook 'tide-format-before-save)
(add-hook 'typescript-mode-hook #'setup-tide-mode)

(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
(add-hook 'web-mode-hook
          (lambda ()
            (when (string-equal "tsx" (file-name-extension buffer-file-name))
              (setup-tide-mode))))
;; enable typescript-tslint checker
(flycheck-add-mode 'typescript-tslint 'web-mode)

(setq tide-format-options '(:indentSize 2 :tabSize: 2 :insertSpaceAfterFunctionKeywordForAnonymousFunctions t :placeOpenBraceOnNewLineForFunctions nil))

;;; Perl-mode
(autoload 'cperl-mode "cperl-mode" "alternate mode for editing Perl programs" t)
(add-to-list 'auto-mode-alist '("\.\([pP][Llm]\|al\|t\|cgi\)\'" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("perl" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("perl5" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("miniperl" . cperl-mode))
(defvar cperl-indent-level 4)
(defvar cperl-continued-statement-offset 4)
(defvar cperl-close-paren-offset -4)
(defvar cperl-label-offset -4)
(defvar cperl-comment-column 40)
(defvar cperl-highlight-variables-indiscriminately t)
(defvar cperl-indent-parens-as-block t)
(defvar cperl-tab-always-indent nil)
(defvar cperl-font-lock t)
;; Perl auto complete
(add-hook 'cperl-mode-hook
          '(lambda ()
             (progn
               (setq indent-tabs-mode nil)
               (setq tab-width nil)
               (require 'perl-completion)
               (add-to-list 'ac-sources 'ac-source-perl-completion)
               (perl-completion-mode t)
              )))
;; Perl tidy
(defun perltidy-region ()
  "Run perltidy on the current region."
  (interactive)
  (save-excursion
    (shell-command-on-region (point) (mark) "perltidy -q" nil t)))
(defun perltidy-defun ()
  "Run perltidy on the current defun."
  (interactive)
  (save-excursion (mark-defun)
                  (perltidy-region)))

;;; Php-mode
(require 'php-mode)

;; Ruby
(setq ruby-insert-encoding-magic-comment nil)

;; Python
(flycheck-define-checker
    python-mypy ""
    :command ("mypy"
              "--ignore-missing-imports"
              source-original)
    :error-patterns
    ((error line-start (file-name) ":" line ": error:" (message) line-end))
    :modes python-mode)

(add-to-list 'flycheck-checkers 'python-mypy t)
(flycheck-add-next-checker 'python-pylint 'python-mypy t)

(add-to-list 'company-backends 'company-jedi)
(add-to-list 'company-backends '(company-jedi company-files))

(require 'blacken)
(add-hook 'python-mode-hook 'blacken-mode)

;;; Rust-mode
(require 'rust-mode)
(require 'flycheck-rust)

(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))

(setq racer-rust-src-path (concat "${HOME}" "/.cargo/src/rustc-nightly-src"))
;; Type the following commands
;; mkdir -pv ${HOME}/.cargo/src
;; curl -L https://static.rust-lang.org/dist/rustc-nightly-src.tar.gz -o ${HOME}/.cargo/src/rustc-nightly-src.tar.gz
;; cd ${HOME}/.cargo/src/; tar xvf ${HOME}/.cargo/src/rustc-nightly-src.tar.gz
(add-hook 'rust-mode-hook (lambda ()
			    (flycheck-rust-setup)
                            (racer-mode)))
(add-hook 'racer-mode-hook #'eldoc-mode)
(add-hook 'racer-mode-hook #'company-mode)

(eval-after-load "rust-mode"
  '(setq-default rust-format-on-save t))

(define-key rust-mode-map (kbd "C-c C-f") #'rust-format-buffer)
(define-key rust-mode-map (kbd "TAB") #'company-indent-or-complete-common)
(defvar company-tooltip-align-annotations t)

;;; Terraform-mode
(require 'terraform-mode)
(custom-set-variables
  '(terraform-indent-level 2))
