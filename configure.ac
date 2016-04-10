dnl niccolo': a chemicals inventory
dnl Copyright (C) 2016  Universita' degli Studi di Palermo

dnl This program is free software: you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation, version 3 of the License.

dnl This program is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU General Public License for more details.

dnl You should have received a copy of the GNU General Public License
dnl along with this program.  If not, see <http://www.gnu.org/licenses/>.

dnl program

AC_INIT([lab],[0.0.1],[],[lab])
AM_INIT_AUTOMAKE([foreign])
AC_SUBST([VERSION],AC_PACKAGE_VERSION)
AC_SUBST([TARNAME],AC_PACKAGE_TARNAME)

AC_SUBST([PACKAGE_NAME],AC_PACKAGE_NAME)

AC_PROG_INSTALL
AC_PATH_PROG([WGET],[wget],[no])
AC_PATH_PROG([SBCL],[sbcl],[no])
AC_PATH_PROG([SCREEN],[screen],[no])
AC_PATH_PROG([QRENCODE],[qrencode],[no])
AC_PATH_PROG([CHMOD],[chmod],[no])

if test $WGET = "no"; then
   AC_MSG_WARN("wget not found: quick_quicklisp.sh will not works")
fi

if test $SBCL = "no"; then
   AC_MSG_ERROR("SBCL not found")
fi

if test $SCREEN = "no"; then
   AC_MSG_ERROR("screen not found")
fi

if test $QRENCODE = "no"; then
   AC_MSG_ERROR("qrencode not found")
fi

if test $CHMOD = "no"; then
   AC_MSG_ERROR("chmod not found")
fi


AC_CONFIG_FILES([Makefile start_server.sh quick_quicklisp.sh script/lab-encode-query.sh])
AC_OUTPUT
