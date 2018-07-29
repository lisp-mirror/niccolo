Table of Contents
─────────────────

1 Introduction
2 Building
.. 2.1 Dependency
..... 2.1.1 Library
..... 2.1.2 External programs
.. 2.2 Installation
3 Authentication
.. 3.1 Internal database of users
.. 3.2 CAS authentication
4 Start server
5 BUGS
.. 5.1 Known bugs
6 License
7 Contributing
8 NO WARRANTY


1 Introduction
══════════════

  Niccolo' is a web based software aimed at safe chemicals storage,
  using and disposing.


2 Building
══════════

  Niccolo' is written in Common Lisp, except for a few of libraries
  (written in C) it depends on.


2.1 Dependency
──────────────

2.1.1 Library
╌╌╌╌╌╌╌╌╌╌╌╌╌

  Niccolo' depends on the following common lisp libraries:

  • alexandria;
  • cl-ppcre-unicode;
  • trivial-timeout;
  • bordeaux-threads;
  • dbi;
  • cl-smtp;
  • cl-sanitize;
  • envy;
  • parse-number;
  • xmls;
  • html-template;
  • cl-base64;
  • osicat;
  • log4cl;
  • ironclad;
  • cl-who;
  • cl-json;
  • flexi-streams;
  • cl-gd;
  • hunchentoot;
  • drakma;
  • restas;
  • restas-directory-publisher;
  • cl-pslib;
  • cl-pslib-barcode;
  • cl-i18n;
  • crane.

  Except for crane (see below) all of them are available from quicklisp.

  For crane a patched version (available [here]), is needed.

  Also be sure to install the following C libraries:

  • libxml2 (needed for cl-sanitize)
  • libgd;
  • libsqlite3;
  • pslib.


[here] https://notabug.org/cage/crane/


2.1.2 External programs
╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌

  • sbcl;
  • wget;
  • sqlite3;
  • screen;
  • gcc;
  • bash;
  • autotools build system (i.e. autoconf, automake etc).


2.2 Installation
────────────────

  Note: Assuming directory ~/lisp exists and is writable.

  Also basic [ASDF] knowledge is mandatory.

  Moreover steps 2-5 and 10-11 may be skipped if you have quicklisp
  already installed and ASDF configured (but you should install all the
  2.1 anyway, via quicklisp).

  1. cd ~/lisp/
  2. wget [https://beta.quicklisp.org/quicklisp.lisp]
  3. wget [https://beta.quicklisp.org/quicklisp.lisp.asc]
  4. wget [https://beta.quicklisp.org/release-key.txt]
  5. check quicklisp gpg key
  6. clone niccolo repository
  7. cd niccolo
  8. autoreconf -fiv
  9. ./configure
  10. cd ~/lisp && bash niccolo/quick_quicklisp.sh (the script will
      download and install most of the libraries, also will help you to
      configure ASDF);
  11. clone [this version of crane] in ~/quicklisp/local-projects;
  12. checkout branch sqlite for crane
  13. cd ~/quicklisp/dists/quicklisp/software/cl-gd-0.6.1
  14. make
  15. cd ~/lisp/niccolo/
  16. make
  17. put your ssl certificate in ssl/
  18. edit config.lisp

      ┌────
      │
      │ (define-constant +path-prefix+ "/niccolo" :test #'string=)
      │
      │ ;; ssl
      │
      │ (define-constant +hostname+   "xxxxxxxxx" :test #'string=)
      │
      │ (defparameter *ssl-certfile* (asdf:system-relative-pathname :lab #p"ssl/xxx.pem"))
      │
      │ (defparameter *ssl-key* (asdf:system-relative-pathname :lab #p"ssl/xxxx.pem"))
      │
      │ (define-constant +ssl-pass+   "xxxxxx" :test #'string=)
      │
      └────

  19. Optional, configure this section for email notifications.

      ┌────
      │ ;; smtp config
      │
      │ ;; you want  actually to use mail  notification? Set this value  to a
      │ ;; non nil value ('t' for example).
      │ (define-constant +use-smtp+            nil                 :test #'eq)
      │
      │ (define-constant +smtp-host+           "localhost"         :test #'string=)
      │
      │ (define-constant +smtp-from-address+   "noreply@localhost" :test #'string=)
      │
      │ (define-constant +smtp-port-address+   465                 :test #'=)
      │
      │ ;; '() for no authentication
      │ (define-constant +smtp-autentication+  '("username" "password") :test #'equalp)
      │
      │ ;; use nil for no ssl
      │ (define-constant +smtp-ssl+             t                       :test #'string=)
      │
      │ (define-constant +smtp-subject-mail-prefix+  "[niccolo] "       :test #'string=)
      │
      └────

  20. Optional (but *strongly not* recommended), use federated-query

      A niccolo server can federate with other software's instances
      (i.e. other servers running the same software) to share parts of
      their database on the net.

      Hopefully there will be some documentation some day in the future,
      in the meanwhile the only documentation are the sources. :(

      *It is not recommended to enable federated query except for study
      or testing purposes*

      ┌────
      │
      │ (define-constant +federated-query-enabled+     nil              :test #'string=)
      │
      │ ;; key for federated query, change it!
      │
      │ (define-constant +federated-query-key+       "/yGHgfè%a6s!"     :test #'string=)
      │
      └────

      furthermore you need to specify a nodes file named
      'nodes-list.expr'

      ┌────
      │
      │ (in-package :federated-query)
      │
      │ (define-nodes-list
      │   (define-node "nome of the federated host" 8443))
      │
      └────

  21. Optional (but *strongly* recommended), use CAS autentication

      ┌────
      │ ;; cas config
      │
      │ (define-constant +cas-server-host-name+    "" :test #'string=)
      │
      │ (define-constant +cas-server-path-prefix+  ""    :test #'string=)
      └────

      you need to compile mini-cas library to use this feature see: 3.2
      below.

  22. Optional (but *strongly* recommended) If you plan to put niccolo
      behind a reverse proxy (and we recommend to do so) also set:

      ┌────
      │ (define-constant +https-proxy-port+ -1 :test #'=)
      └────

      to the actual port (usually 443) where your http server is
      listening on the internet/intranet.

  23. Sensors and data logger

      The directory sensors/temp and sensors/gas contains two loggers
      for arduino compatible with the protocol implemented for this
      software (essentially http with MAC authentication).

      To build the software you will need:
      • For temperature monitoring
        ⁃ Hardware
          • an arduino with a ethernet shield;
          • DS18B20 temperature sensor.
        ⁃ Software
          • the arduino IDE and these libraries not bundled with the IDE
            ⁃ [https://github.com/PaulStoffregen/OneWire]
            ⁃ [https://github.com/milesburton/Arduino-Temperature-Control-Library]
      • For gas monitoring
        ⁃ Hardware
          • an arduino with a ethernet shield;
          • MQ135 gas sensor.
        ⁃ Software
          • the arduino IDE

  24. `sh 'start_server.sh'' (or `sh 'start_server-cas.sh'' if you are
      using [the CAS authentication protocol])

  25. point your browser to
      `https://+hostname+:(+https-poxy-port+|+https-port+)/+path-prefix+/add-admin/'
      where `+hostname+' and `+path-prefix+' are the values of the
      variables setted in point 19, also specify the actual port your
      server is listening on the internet (`+https-poxy-port+' or
      `+https-port+') to generate the administrator account.


[ASDF] https://www.common-lisp.net/project/asdf/

[this version of crane] https://notabug.org/cage/crane/

[the CAS authentication protocol] See section 3.2


3 Authentication
════════════════

  Niccolo comes with two kinds of autenthication mechanisms.


3.1 Internal database of users
──────────────────────────────

  The first is based on an table in its own database which stores
  username/password.

  We *does not* recommend using this kind of authentication as it was
  developed just for testing purposes.


3.2 CAS authentication
──────────────────────

  Niccolo includes a [CAS] client library (in …/lib/ directory) for
  authentication, this is what we use in our production environment.

  To enable CAS authentication just put the mini-cas directory in a
  place where ASDF is going to be able to find (load, actually) it,
  niccolo will use CAS automatically.  Then edit config.lisp in the CAS
  section.

  If mini-cas is not loaded with ASDF niccolo' will use internal
  authentication instead.

  Please note that, depending of the content of your
  source-registry.conf file (expecially if you use the :tree options),
  …/lib/mini-cas/ *will* be reached by ASDF.


[CAS]
https://github.com/Jasig/cas/blob/master/cas-server-documentation/protocol/CAS-Protocol-Specification.md


4 Start server
══════════════

  Use the 'start_server.sh' or 'start_server-cas.sh' scripts to start
  the server without or with CAS authentication respectively.


5 BUGS
══════

  Please send bug report to cage-dev at twistfold dot it


5.1 Known bugs
──────────────

  • federated query works only in sbcl.
  • not strictly a bug maybe, but mq135 is very sensible to humidity and
    temperature variation.


6 License
═════════

  This program is Copyright (C) 2016 Universita' degli Studi di Palermo
  and released under GNU General Public license version 3 (see COPYING
  file).

  The program use data and code from other sources, please see
  LICENSE.org.

  Although any efforts has been put to make the list of credits
  exaustive, errors are always possible.  Please send correction to
  cage-dev at twistfold dot it.


7 Contributing
══════════════

  Any help is appreciated. Please send a message to cage-dev at
  twistfold dot it.


8 NO WARRANTY
═════════════

  niccolo': a chemicals inventory Copyright (C) 2016 Universita' degli
  Studi di Palermo

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, version 3 of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see [http://www.gnu.org/licenses/].
