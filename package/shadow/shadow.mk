################################################################################
#
# shadow
#
################################################################################

SHADOW_VERSION = 4.2.1
SHADOW_SOURCE = shadow-$(SHADOW_VERSION).tar.xz
SHADOW_SITE = http://download.savannah.gnu.org/releases/shadow
SHADOW_INSTALL_STAGING = NO
SHADOW_LICENSE = GPLv2+ (programs), LGPLv2.1+ (libraries)
SHADOW_LICENSE_FILES = doc/COPYING doc/COPYING.LGPL

SHADOW_CONF_OPTS = --sysconfdir=/etc \
	--with-group-name-max-length=32 \
	--enable-subordinate-ids=no \
	--with-libpam=no

$(eval $(autotools-package))
