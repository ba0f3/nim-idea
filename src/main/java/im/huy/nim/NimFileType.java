package im.huy.nim;

import com.intellij.openapi.fileTypes.LanguageFileType;

import javax.swing.*;

/**
 * Created by huy on 6/15/15.
 */
public class NimFileType extends LanguageFileType {
    public static final NimFileType INSTANCE = new NimFileType();

    private NimFileType() {
        super(NimLanguage.INSTANCE);
    }


    public String getName() {
        return "Nim Source";
    }

    public String getDescription() {
        return "Nim language source code";
    }

    public String getDefaultExtension() {
        return "nim";
    }

    public Icon getIcon() {
        return NimIcons.ICON_NIM_16;
    }
}
