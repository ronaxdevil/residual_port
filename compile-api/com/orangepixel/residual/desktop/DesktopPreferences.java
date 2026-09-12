// Compile-only API declaration. Excluded from the distributed host.
package com.orangepixel.residual.desktop;

public class DesktopPreferences implements com.orangepixel.plugins.OrangePreferences {
    public String getDefaultPreferencesDirectory() { throw new UnsupportedOperationException(); }
    public com.badlogic.gdx.Files.FileType getDefaultPreferencesFileType() { throw new UnsupportedOperationException(); }
}
