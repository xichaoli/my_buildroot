# This file contains toolchain-related customisation of the content
# of the target/ directory. Those customisations are added to the
# TARGET_FINALIZE_HOOKS, to be applied just after all packages
# have been built.

# Install default nsswitch.conf file if the skeleton doesn't provide it
ifeq ($(BR2_TOOLCHAIN_USES_GLIBC),y)
define GLIBC_COPY_NSSWITCH_FILE
	$(Q)if [ ! -f "$(TARGET_DIR)/etc/nsswitch.conf" ]; then \
		$(INSTALL) -D -m 0644 package/glibc/nsswitch.conf $(TARGET_DIR)/etc/nsswitch.conf ; \
	fi
endef
TOOLCHAIN_TARGET_FINALIZE_HOOKS += GLIBC_COPY_NSSWITCH_FILE
endif

# Install the elf programs to target,such as ldd,ldconfig
ELF_PROGRAMS = $(call qstrip,$(BR2_TOOLCHAIN_GLIBC_ELF_LIST))
define COPY_ELF_PROGRAMS
	if [ -n "$(ELF_PROGRAMS)" ]; then \
		for l in $(ELF_PROGRAMS); do \
			$(INSTALL) -m 0755 -D $(STAGING_DIR)/$${l} \
				$(TARGET_DIR)/$${l} \
			|| exit 1; \
		done; \
	fi
endef
TARGET_FINALIZE_HOOKS += COPY_ELF_PROGRAMS

# Install the gconv modules
ifeq ($(BR2_TOOLCHAIN_GLIBC_GCONV_LIBS_COPY),y)
GCONV_LIBS = $(call qstrip,$(BR2_TOOLCHAIN_GLIBC_GCONV_LIBS_LIST))
define COPY_GCONV_LIBS
	$(Q)found_gconv=no; \
	for d in $(TOOLCHAIN_EXTERNAL_PREFIX) ''; do \
		[ -d "$(STAGING_DIR)/usr/lib/$${d}/gconv" ] || continue; \
		found_gconv=yes; \
		break; \
	done; \
	if [ "$${found_gconv}" = "no" ]; then \
		printf "Unable to find gconv modules\n" >&2; \
		exit 1; \
	fi; \
	if [ -z "$(GCONV_LIBS)" ]; then \
		$(INSTALL) -m 0644 -D $(STAGING_DIR)/usr/lib/$${d}/gconv/gconv-modules \
				      $(TARGET_DIR)/usr/lib/gconv/gconv-modules && \
		$(INSTALL) -m 0644 $(STAGING_DIR)/usr/lib/$${d}/gconv/*.so \
				   $(TARGET_DIR)/usr/lib/gconv \
		|| exit 1; \
	else \
		for l in $(GCONV_LIBS); do \
			$(INSTALL) -m 0644 -D $(STAGING_DIR)/usr/lib/$${d}/gconv/$${l}.so \
					      $(TARGET_DIR)/usr/lib/gconv/$${l}.so \
			|| exit 1; \
			$(TARGET_READELF) -d $(STAGING_DIR)/usr/lib/$${d}/gconv/$${l}.so |\
			sort -u |\
			sed -e '/.*(NEEDED).*\[\(.*\.so\)\]$$/!d; s//\1/;' |\
			while read lib; do \
				 $(INSTALL) -m 0644 -D $(STAGING_DIR)/usr/lib/$${d}/gconv/$${lib} \
						       $(TARGET_DIR)/usr/lib/gconv/$${lib} \
				 || exit 1; \
			done; \
		done; \
		./support/scripts/expunge-gconv-modules "$(GCONV_LIBS)" \
			<$(STAGING_DIR)/usr/lib/$${d}/gconv/gconv-modules \
			>$(TARGET_DIR)/usr/lib/gconv/gconv-modules; \
	fi
endef
TOOLCHAIN_TARGET_FINALIZE_HOOKS += COPY_GCONV_LIBS
endif
