;;; SLIME

(setq inferior-lisp-program "/usr/bin/sbcl"
  lisp-indent-function 'common-lisp-indent-function)
(add-to-list 'load-path "/usr/share/emacs/site-lisp/slime")
(global-set-key "\C-cs" 'slime-selector)


(eval-after-load "slime"
'(progn
(setq slime-lisp-implementations
'((sbcl ("/usr/bin/sbcl"))
(clisp ("/usr/bin/clisp")))
common-lisp-hyperspec-root "/usr/share/doc/HyperSpec/")

(slime-setup '(slime-asdf
slime-autodoc
slime-editing-commands
slime-fancy
slime-fancy-inspector
slime-fontifying-fu
slime-fuzzy
slime-indentation
slime-mdot-fu
slime-package-fu
slime-references
slime-repl
slime-sbcl-exts
slime-scratch
slime-xref-browser))
(slime-autodoc-mode)
(setq slime-complete-symbol*-fancy t)
(setq slime-complete-symbol-function 'slime-fuzzy-complete-symbol)
(add-hook 'lisp-mode-hook (lambda () (slime-mode t)))))

(require 'slime)
(require'slime-autoloads)
(put 'upcase-region 'disabled nil)
