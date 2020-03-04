package app.eeui.framework.extend.integration.iconify.fonts;

import app.eeui.framework.extend.integration.iconify.Icon;
import app.eeui.framework.extend.integration.iconify.IconFontDescriptor;

public class IoniconsModule implements IconFontDescriptor {

    @Override
    public String ttfFileName() {
        return "iconify/eeuiicon.ttf";
    }

    @Override
    public Icon[] characters() {
        return IoniconsIcons.values();
    }
}
