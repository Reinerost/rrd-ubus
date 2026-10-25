include $(TOPDIR)/rules.mk

PKG_NAME:=rrd-ubus
PKG_VERSION:=0.2
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/rrd-ubus
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=RRDtool rpcd XPORT plugin
  DEPENDS:=+rpcd +libubus +libubox +libuci +librrd
endef

define Package/rrd-ubus/description
  Provides RRDtool XPORT data through an rpcd plugin.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/rrd-ubus.c $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_CPPFLAGS) \
		-fPIC -shared \
		-o $(PKG_BUILD_DIR)/rrd.so \
		$(PKG_BUILD_DIR)/rrd-ubus.c \
		$(TARGET_LDFLAGS) -lubus -lubox -luci -lrrd
endef

define Package/rrd-ubus/install
	$(INSTALL_DIR) $(1)/usr/lib/rpcd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rrd.so $(1)/usr/lib/rpcd/
endef

define Package/rrd-ubus/postinst
#!/bin/sh
[ -n "$$IPKG_INSTROOT" ] || /etc/init.d/rpcd reload
endef

$(eval $(call BuildPackage,rrd-ubus))
