package im.huy.nim;

import com.intellij.lang.Language;

/**
 * Created by huy on 6/15/15.
 */
public class NimLanguage extends Language {
    public static final NimLanguage INSTANCE = new NimLanguage();

    private NimLanguage() {
        super("Nim", "text/nim", "text/x-nim", "application/x-nim");
    }

    @Override
    public boolean isCaseSensitive() {
        return false;
    }

    @Override
    public String getDisplayName() {
        return "Nim";
    }
}
