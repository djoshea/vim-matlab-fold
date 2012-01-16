===============
vim-matlab-fold
===============

Code folding for the Vim editor for Matlab ``.m`` syntax files. Facilitates folding
of any indented block of matlab code or editor cells beginning with ``%%``.

Folds are based off of the indentation structure in the code, in a manner which 
respects the ``end`` keyword and line continuations ending in ``...``. Accordingly,
you must indent the body of a function block in order for it to be foldable. Any 
code block is foldable if the contents are indented, including ``function``, 
``if``, ``else``, ``for``, ``while``, ``try``, ``properties``, ``methods``, etc.

Installation
===============

First, I highly recommend installing the Matlab syntax and indent files authored
by `Fabrice Guy`_ available `here`_.
These files will facilitate proper indentation of Matlab files which this script
relies upon to do code folding.

.. _`Fabrice Guy`: http://www.vim.org/account/profile.php?user_id=15324
.. _`here`: http://www.vim.org/scripts/script.php?script_id=2407

Install to ``~/.vim/ftplugin/matlab_fold.vim``. Or, copy and paste::

    mkdir -p ~/.vim/ftplugin \ 
    curl -so ~/.vim/ftplugin/matlab_fold.vim \
        https://raw.github.com/djoshea/vim-matlab-fold/HEAD/ftplugin/matlab_fold.vim

If you're using `Pathogen`_, install to ``~/.vim/bundle/vim-matlab-fold/ftplugin/matlab_fold.vim``.

.. _`Pathogen`: http://github.com/tpope/vim-pathogen

Or, copy and paste::

    mkdir -p ~/.vim/bundle/vim-matlab-fold/ftplugin \ 
    curl -so ~/.vim/bundle/vim-matlab-fold/ftplugin/matlab_fold.vim \
        https://raw.github.com/djoshea/vim-matlab-fold/HEAD/ftplugin/matlab_fold.vim

Or, you can clone the git repository into a pathogen bundle::

    git clone git://github.com/djoshea/vim-matlab-fold.git ~/.vim/bundle/vim-matlab-fold

Screenshots
===============

Editing a class definition file:

.. image:: http://cloud.github.com/downloads/djoshea/vim-matlab-fold/vim-matlab-fold.png
   :alt: vim-matlab-fold Screenshot
   :align: center

License
===============

Copyright (c) `Dan O'Shea`_.  Distributed under the same terms as Vim itself.
See ``:help license``.

.. _`Dan O'Shea`: http://djoshea.com
